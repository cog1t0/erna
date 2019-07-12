Rails.application.routes.draw do
  root to: 'home#index'
  post '/webhook' => 'api/v1/webhook#webhook'
  resources :maps
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
