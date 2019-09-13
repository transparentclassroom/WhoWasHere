Rails.application.routes.draw do
  root to: 'landing#show'

  resources :logs
  resources :sparklines
end
