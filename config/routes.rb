require 'sidekiq/web'

Rails.application.routes.draw do
  mount Sidekiq::Web => '/sidekiq'

  devise_for :users, controllers: {
    sessions: 'users/sessions'
  }

  devise_scope :user do
    # Route for showing user information
    get 'users/:id', to: 'users/sessions#show', as: :user_show

    # Route for updating user information
    put 'users/:id', to: 'users/sessions#update_info', as: :user_update_info

    # Routes for Google OAuth
    namespace :users do
      resource :sessions, only: [] do
        collection do
          get :google_oauth_url
          get :google_oauth_callback
        end
      end
    end
  end

  namespace :api do
    namespace :v1 do
      resources :tasks
      resources :lists do
        resources :tasks
      end
    end
  end
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
end
