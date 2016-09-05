require 'sidekiq/web'

Rails.application.routes.draw do
  mount ActionCable.server => '/cable'

  authenticate :user, lambda { |u| u.admin? } do
    mount Sidekiq::Web => '/sidekiq'
  end

  use_doorkeeper do
    controllers applications: 'oauth/applications'
  end

  get '.well-known/host-meta', to: 'xrd#host_meta', as: :host_meta
  get '.well-known/webfinger', to: 'xrd#webfinger', as: :webfinger

  devise_for :users, path: 'auth', controllers: {
    sessions:           'auth/sessions',
    registrations:      'auth/registrations',
    passwords:          'auth/passwords'
  }

  resources :accounts, path: 'users', only: [:show], param: :username do
    resources :stream_entries, path: 'updates', only: [:show]

    member do
      get :followers
      get :following
    end
  end

  resource  :settings, only: [:show, :update]

  namespace :api do
    # PubSubHubbub
    resources :subscriptions, only: [:show]
    post '/subscriptions/:id', to: 'subscriptions#update'

    # Salmon
    post '/salmon/:id', to: 'salmon#update', as: :salmon

    # JSON / REST API
    resources :statuses, only: [:create, :show] do
      collection do
        get :home
        get :mentions
      end

      member do
        post :reblog
        post :favourite
      end
    end

    resources :follows,  only: [:create]
    resources :media,    only: [:create]

    resources :accounts, only: [:show] do
      collection do
        get :lookup, to: 'accounts/lookup#index', as: :lookup
      end

      member do
        get :statuses
        get :followers
        get :following

        post :follow
        post :unfollow
      end
    end
  end

  root 'home#index'
end
