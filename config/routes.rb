Rails.application.routes.draw do
  get '.well-known/host-meta', to: 'xrd#host_meta', as: :host_meta
  get '.well-known/webfinger', to: 'xrd#webfinger', as: :webfinger

  get 'atom/:id',   to: 'atom#user_stream', as: :atom_user_stream
  get 'user/:name', to: 'profile#show', as: :profile

  mount Mastodon::API => '/api/'

  root 'home#index'
end
