Rails.application.routes.draw do
  get '.well-known/host-meta', to: 'xrd#host_meta', as: :host_meta
  get '.well-known/webfinger', to: 'xrd#webfinger', as: :webfinger

  get 'atom/entries/:id', to: 'atom#entry',       as: :atom_entry
  get 'atom/users/:id',   to: 'atom#user_stream', as: :atom_user_stream
  get 'users/:name',      to: 'profile#show',     as: :profile
  get 'users/:name/:id',  to: 'profile#entry',    as: :status

  mount Mastodon::API => '/api/'

  root 'home#index'
end
