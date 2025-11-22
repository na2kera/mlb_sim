Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # API v1
  namespace :api do
    namespace :v1 do
      # チーム一覧取得
      resources :teams, only: [:index]

      # スケジュール取得
      get 'schedule', to: 'schedules#index'

      # ライブゲーム情報取得
      get 'game/:game_pk/feed/live', to: 'live_feeds#show'

      # シミュレーション機能
      resources :games, only: [:create] do
        member do
          post :start
          post :finish
        end
        resources :innings, only: [:update], param: :inning_number do
          # PUT /api/v1/games/:game_id/innings/:inning_number
        end
      end
    end
  end

  # Defines the root path route ("/")
  # root "posts#index"
end
