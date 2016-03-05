Rails.application.routes.draw do
  get '.well-known/host-meta', to: 'xrd#host_meta', as: :host_meta
  get '.well-known/webfinger', to: 'xrd#webfinger', as: :webfinger

  devise_for :users, path: 'auth', controllers: {
    sessions:           'auth/sessions',
    registrations:      'auth/registrations',
    passwords:          'auth/passwords'
  }

  resources :accounts, path: 'users', only: [:show], param: :username do
    resources :stream_entries, path: 'updates', only: [:show]
  end

  namespace :api do
    resources :subscriptions, only: [:show]
    post '/subscriptions/:id', to: 'subscriptions#update'
    post '/salmon/:id', to: 'salmon#update', as: :salmon
  end

  root 'home#index'
end
