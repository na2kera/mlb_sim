module Api
  module V1
    class InningsController < ApplicationController
      before_action :set_game
      before_action :validate_game_in_progress

      # PUT /api/v1/games/:game_id/innings/:inning_number
      def update
        inning_number = params[:inning_number].to_i
        half = inning_params[:half]

        # 既存のイニングを探すか新規作成
        @inning = @game.innings.find_or_initialize_by(
          inning_number: inning_number,
          half: half
        )

        @inning.assign_attributes(
          runs: inning_params[:runs],
          hits: inning_params[:hits],
          error_count: inning_params[:errors]
        )

        if @inning.save
          render json: inning_update_response(@game), status: :ok
        else
          render json: error_response("INVALID_PARAMETER", @inning.errors.full_messages.join(", ")), status: :bad_request
        end
      rescue StandardError => e
        render json: error_response("SERVER_ERROR", e.message), status: :internal_server_error
      end

      private

      def set_game
        @game = Game.find_by(game_pk: params[:game_id])
        render json: error_response("NOT_FOUND", "Game not found"), status: :not_found unless @game
      end

      def validate_game_in_progress
        unless @game.status == Game::STATUSES[:in_progress]
          render json: error_response("STATE_TRANSITION_ERROR", "Game is not in progress"), status: :conflict
        end
      end

      def inning_params
        params.require(:inning).permit(:half, :runs, :hits, :errors)
      end

      def inning_update_response(game)
        home_totals = game.total_score_for_team(:home)
        away_totals = game.total_score_for_team(:away)

        {
          gamePk: game.game_pk,
          liveData: {
            linescore: {
              currentInning: game.current_inning_number,
              currentInningOrdinal: ordinal_number(game.current_inning_number),
              inningState: game.current_inning_state,
              teams: {
                home: home_totals,
                away: away_totals
              },
              innings: innings_array(game)
            }
          }
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
