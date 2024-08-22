# config/routes.rb

Rails.application.routes.draw do
  devise_for :admins, only: [ :sessions ], controllers: {
    sessions: "admins/sessions"
  }

  root "dashboard#dashboard"

  get "dashboard", to: "dashboard#dashboard", as: "dashboard"
  resources :tournaments

  resources :basketball_teams do
    member do
      get :details
      get :export_pdf, defaults: { format: :pdf }
    end
    resources :players
    resources :coaches
  end
end
