Rails.application.routes.draw do
  root to: 'landing#show'

  resources :visits
  resources :logs
  resources :sparklines
end
