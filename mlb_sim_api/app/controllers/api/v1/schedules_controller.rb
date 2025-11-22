module Api
  module V1
    class SchedulesController < ApplicationController
      # GET /api/v1/schedule
      def index
        # パラメータ取得
        sport_id = params[:sportId] || 1
        team_id = params[:teamId]
        date = params[:date]

        # バリデーション
        if team_id.blank?
          return render json: error_response("INVALID_PARAMETER", "teamId is required"), status: :bad_request
        end

        if date.blank?
          return render json: error_response("INVALID_PARAMETER", "date is required"), status: :bad_request
        end

        # 日付フォーマットチェック
        begin
          parsed_date = Date.parse(date)
        rescue ArgumentError
          return render json: error_response("INVALID_PARAMETER", "date must be YYYY-MM-DD"), status: :bad_request
        end

        # チーム存在チェック
        team = Team.find_by(mlb_id: team_id) || Team.find_by(id: team_id)
        unless team
          return render json: error_response("NOT_FOUND", "Team not found"), status: :not_found
        end

        # 指定日のゲームを取得（ホームまたはアウェイ）
        games = Game.where("DATE(date) = ?", parsed_date)
                    .where("home_team_id = ? OR visitor_team_id = ?", team.id, team.id)
                    .order(:date)

        render json: {
          dates: [
            {
              date: parsed_date.strftime("%Y-%m-%d"),
              games: games.map { |game| game_summary(game) }
            }
          ]
        }, status: :ok
      rescue StandardError => e
        render json: error_response("SERVER_ERROR", e.message), status: :internal_server_error
      end

      private

      def game_summary(game)
        {
          gamePk: game.game_pk,
          gameDate: game.date.iso8601,
          status: {
            detailedState: game.status,
            abstractGameState: abstract_game_state(game.status)
          },
          teams: {
            home: {
              team: {
                id: game.home_team.mlb_id || game.home_team.id,
                name: game.home_team.name,
                abbreviation: game.home_team.abbreviation
              }
            },
            away: {
              team: {
                id: game.visitor_team.mlb_id || game.visitor_team.id,
                name: game.visitor_team.name,
                abbreviation: game.visitor_team.abbreviation
              }
            }
          }
        }
      end

      def abstract_game_state(status)
        case status
        when Game::STATUSES[:scheduled]
          "Preview"
        when Game::STATUSES[:in_progress]
          "Live"
        when Game::STATUSES[:final]
          "Final"
        else
          "Preview"
        end
      end

      def error_response(error_code, message)
        {
          error: error_code,
          message: message
        }
      end
    end
  end
end
