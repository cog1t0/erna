Rails.application.routes.draw do
  root to: 'home#index'
  post '/webhook' => 'api/v1/webhook#webhook'
  post '/api/v1/addMap' => 'api/v1/webhook#add_map'
  resources :maps
end
