module Api
  module V1
    class TeamsController < ApplicationController
      # GET /api/v1/teams
      def index
        sport_id = params[:sportId] || 1

        # sportIdのバリデーション
        unless sport_id.to_i > 0
          return render json: error_response("INVALID_PARAMETER", "sportId must be a positive integer"), status: :bad_request
        end

        # 全チームを取得（MLB固定なのでsportIdは実質無視）
        teams = Team.all.order(:mlb_id)

        render json: {
          teams: teams.map { |team| team_detail(team) }
        }, status: :ok
      rescue StandardError => e
        render json: error_response("SERVER_ERROR", e.message), status: :internal_server_error
      end

      private

      def team_detail(team)
        {
          id: team.mlb_id || team.id,
          mlbId: team.mlb_id,
          recordId: team.id,
          name: team.name,
          abbreviation: team.abbreviation,
          locationName: team.location_name,
          venue: {
            name: "#{team.location_name} Stadium" # ダミーデータ
          }
        }
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
