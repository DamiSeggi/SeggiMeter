Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  root "lobbies#index"

  # Authentication
  get "login", to: "sessions#new", as: :login
  post "login", to: "sessions#create"
  match "logout", to: "sessions#destroy", via: [:get, :delete], as: :logout

  # Lobbies / Questions
  get "questions", to: "lobbies#index", as: :questions
  resources :lobbies do
    member do
      post :lock
      post :unlock
    end
    resources :submissions, only: [:create]
  end

  # User Profile
  resource :profile, only: [:show, :update]

  # Admin Panel (manually accessed via /admin)
  get  "admin",                       to: "admin/users#index",        as: :admin_users
  delete "admin/:id",                 to: "admin/users#destroy",      as: :admin_user
  patch  "admin/:id/toggle_admin",    to: "admin/users#toggle_admin", as: :toggle_admin_admin_user
end
