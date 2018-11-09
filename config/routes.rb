Rails.application.routes.draw do
  resources :recognitions
  resources :statistics
  root 'recognitions#index'

  # OptOutLinks
  get '/optout', to: 'opt_out_links#optout', as: :optout

  # Shib/AD auth
  get "/signin", to: 'sessions#new', as: :signin
  get "/auth/shibboleth", as: :shibboleth
  get "/auth/developer", to: 'sessions#developer', as: :developer
  match "/auth/shibboleth/callback" => "sessions#shibboleth", as: :callback, via: [:get, :post]
  match "/signout" => "sessions#destroy", as: :signout, via: [:get, :post]
  match "/auth/failure", to: 'sessions#failure', as: :failed_signin, via: [:get, :post]
end
