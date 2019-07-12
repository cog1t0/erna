Rails.application.routes.draw do
  root to: 'home#index'
  post '/webhook' => 'api/v1/webhook#webhook'
  resources :maps
end
