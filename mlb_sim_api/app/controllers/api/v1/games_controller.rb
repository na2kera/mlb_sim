module Api
  module V1
    class GamesController < ApplicationController
      before_action :set_game, only: [:start, :finish]

      # POST /api/v1/games
      def create
        @game = Game.new(game_params)
        @game.status = Game::STATUSES[:scheduled]

        if @game.save
          render json: game_response(@game), status: :created
        else
          render json: error_response("INVALID_PARAMETER", @game.errors.full_messages.join(", ")), status: :bad_request
        end
      rescue StandardError => e
        render json: error_response("SERVER_ERROR", e.message), status: :internal_server_error
      end

      # POST /api/v1/games/:id/start
      def start
        @game.start!
        render json: game_start_response(@game), status: :ok
      rescue StandardError => e
        render json: error_response("STATE_TRANSITION_ERROR", e.message), status: :conflict
      end

      # POST /api/v1/games/:id/finish
      def finish
        @game.finish!
        render json: game_finish_response(@game), status: :ok
      rescue StandardError => e
        if e.message.include?("at least 9 innings")
          render json: error_response("INVALID_OPERATION", e.message), status: :bad_request
        else
          render json: error_response("STATE_TRANSITION_ERROR", e.message), status: :conflict
        end
      end

      private

      def set_game
        @game = Game.find_by(game_pk: params[:id])
        render json: error_response("NOT_FOUND", "Game not found"), status: :not_found unless @game
      end

      def game_params
        params.require(:game).permit(:homeTeamId, :awayTeamId, :gameDate).tap do |p|
          # camelCaseからsnake_caseへの変換
          p[:home_team_id] = p.delete(:homeTeamId) if p[:homeTeamId]
          p[:visitor_team_id] = p.delete(:awayTeamId) if p[:awayTeamId]
          p[:date] = p.delete(:gameDate) if p[:gameDate]
        end
      end

      def game_response(game)
        {
          gamePk: game.game_pk,
          gameDate: game.date.iso8601,
          status: {
            detailedState: game.status,
            abstractGameState: abstract_game_state(game.status)
          },
          teams: {
            home: {
              team: team_info(game.home_team)
            },
            away: {
              team: team_info(game.visitor_team)
            }
          }
        }
      end

      def game_start_response(game)
        {
          gamePk: game.game_pk,
          status: {
            detailedState: game.status,
            abstractGameState: abstract_game_state(game.status)
          },
          liveData: {
            linescore: linescore_data(game)
          }
        }
      end

      def game_finish_response(game)
        home_totals = game.total_score_for_team(:home)
        away_totals = game.total_score_for_team(:away)

        {
          gamePk: game.game_pk,
          status: {
            detailedState: game.status,
            abstractGameState: abstract_game_state(game.status)
          },
          liveData: {
            linescore: {
              teams: {
                home: home_totals,
                away: away_totals
              }
            }
          }
        }
      end

      def linescore_data(game)
        home_totals = game.total_score_for_team(:home)
        away_totals = game.total_score_for_team(:away)

        {
          currentInning: game.current_inning_number,
          currentInningOrdinal: ordinal_number(game.current_inning_number),
          inningState: game.current_inning_state,
          teams: {
            home: home_totals,
            away: away_totals
          },
          innings: innings_array(game)
        }
      end

      def innings_array(game)
        innings_by_number = game.innings.ordered.group_by(&:inning_number)
        innings_by_number.map do |num, inning_halves|
          top_inning = inning_halves.find { |i| i.half == "top" }
          bottom_inning = inning_halves.find { |i| i.half == "bottom" }

          {
            num: num,
            ordinalNum: ordinal_number(num),
            home: bottom_inning ? { runs: bottom_inning.runs, hits: bottom_inning.hits, errors: bottom_inning.error_count } : { runs: 0, hits: 0, errors: 0 },
            away: top_inning ? { runs: top_inning.runs, hits: top_inning.hits, errors: top_inning.error_count } : { runs: 0, hits: 0, errors: 0 }
          }
        end
      end

      def team_info(team)
        {
          id: team.mlb_id || team.id,
          name: team.name,
          abbreviation: team.abbreviation
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

      def ordinal_number(num)
        case num
        when 1 then "1st"
        when 2 then "2nd"
        when 3 then "3rd"
        else "#{num}th"
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
