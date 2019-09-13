Rails.application.routes.draw do
  root to: 'landing#show'

  resources :visits
  resources :logs

  resources :schools do
    resources :sparklines
    resources :visits
  end

  resources :users do
    resources :visits
  end
end
