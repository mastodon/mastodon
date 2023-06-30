Subscription::Engine.routes.draw do
  post '/webhooks', to: 'webhooks#receive'

  resources :subscriptions, only: [:index, :show]
end
