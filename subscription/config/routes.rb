Subscription::Engine.routes.draw do
  post '/webhooks', to: 'webhooks#receive'

  resources :subscriptions, only: [:index, :create] do
    post :join, on: :collection
  end

  namespace :api do
    resources :invites, only: [:index]
  end
end
