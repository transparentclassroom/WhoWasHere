Rails.application.routes.draw do
  root to: "landing#show"
  get "/auth/:provider/callback", to: "sessions#create"
  get "/logout", to: "sessions#destroy"

  resources :visits

  resources :schools do
    resources :visits
  end

  resources :users do
    resources :visits
  end

  resources :logs

  namespace :api do
    resources :schools, only: [] do
      resources :sparklines
    end
  end
end
