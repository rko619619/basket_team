# config/routes.rb

Rails.application.routes.draw do
  devise_for :admins, only: [ :sessions ], controllers: {
    sessions: "admins/sessions"
  }

  root "dashboard#dashboard"

  get "dashboard", to: "dashboard#dashboard", as: "dashboard"
  resources :basketball_teams do
    member do
      get :details
    end
    resources :players
  end
end
