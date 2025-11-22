module Api
  module V1
    class LiveFeedsController < ApplicationController
      # GET /api/v1/game/:game_pk/feed/live
      def show
        game_pk = params[:game_pk]

        # ゲーム取得
        @game = Game.find_by(game_pk: game_pk)
        unless @game
          return render json: error_response("NOT_FOUND", "Game not found"), status: :not_found
        end

        render json: live_feed_response(@game), status: :ok
      rescue StandardError => e
        render json: error_response("SERVER_ERROR", e.message), status: :internal_server_error
      end

      private

      def live_feed_response(game)
        {
          gameData: {
            teams: {
              home: {
                id: game.home_team.mlb_id || game.home_team.id,
                name: game.home_team.name,
                abbreviation: game.home_team.abbreviation
              },
              away: {
                id: game.visitor_team.mlb_id || game.visitor_team.id,
                name: game.visitor_team.name,
                abbreviation: game.visitor_team.abbreviation
              }
            }
          },
          liveData: {
            linescore: linescore_data(game),
            plays: plays_data(game)
          }
        }
      end

      def linescore_data(game)
        home_totals = game.total_score_for_team(:home)
        away_totals = game.total_score_for_team(:away)

        {
          currentInning: game.current_inning_number,
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

      def plays_data(game)
        # スコアリングプレイのインデックスを収集
        scoring_play_indices = []
        game.innings.ordered.each_with_index do |inning, index|
          scoring_play_indices << index if inning.runs > 0
        end

        {
          allPlays: generate_all_plays(game),
          scoringPlays: scoring_play_indices
        }
      end

      def generate_all_plays(game)
        all_plays = []
        game.innings.ordered.each_with_index do |inning, index|
          # 各イニングのプレイを生成（ダミーデータ）
          if inning.runs > 0
            all_plays << {
              about: {
                atBatIndex: index,
                result: inning.runs > 1 ? "Home Run" : "Single",
                isScoringPlay: true
              },
              result: {
                description: "#{inning.runs} run(s) scored in #{ordinal_number(inning.inning_number)} #{inning.half}",
                event: inning.runs > 1 ? "Home Run" : "Single",
                rbi: inning.runs
              },
              matchup: {
                batter: {
                  fullName: "Player #{index + 1}"
                }
              }
            }
          end
        end
        all_plays
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
