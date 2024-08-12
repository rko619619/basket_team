# config/routes.rb

Rails.application.routes.draw do
  devise_for :admins, only: [:sessions], controllers: {
    sessions: 'admins/sessions'
  }

  root "admin#dashboard"

  resource :dashboard, only: [:show], controller: 'admins/dashboard'
  resources :basketball_teams
end