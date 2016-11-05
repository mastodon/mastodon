require 'sidekiq/web'

Rails.application.routes.draw do
  get 'tags/show'

  mount ActionCable.server => '/cable'

  authenticate :user, lambda { |u| u.admin? } do
    mount Sidekiq::Web => '/sidekiq'
    mount PgHero::Engine, at: 'pghero'
  end

  use_doorkeeper do
    controllers authorizations: 'oauth/authorizations'
  end

  get '.well-known/host-meta', to: 'xrd#host_meta', as: :host_meta
  get '.well-known/webfinger', to: 'xrd#webfinger', as: :webfinger

  devise_for :users, path: 'auth', controllers: {
    sessions:           'auth/sessions',
    registrations:      'auth/registrations',
    passwords:          'auth/passwords',
    confirmations:      'auth/confirmations'
  }

  resources :accounts, path: 'users', only: [:show], param: :username do
    resources :stream_entries, path: 'updates', only: [:show]

    member do
      get :followers
      get :following

      post :follow
      post :unfollow
    end
  end

  namespace :settings do
    resource :profile, only: [:show, :update]
    resource :preferences, only: [:show, :update]
  end

  resources :media, only: [:show]
  resources :tags,  only: [:show]

  namespace :api do
    # PubSubHubbub
    resources :subscriptions, only: [:show]
    post '/subscriptions/:id', to: 'subscriptions#update'

    # Salmon
    post '/salmon/:id', to: 'salmon#update', as: :salmon

    # JSON / REST API
    namespace :v1 do
      resources :statuses, only: [:create, :show, :destroy] do
        collection do
          get :home
          get :mentions
          get :public
          get '/tag/:id', action: :tag
        end

        member do
          get :context
          get :reblogged_by
          get :favourited_by

          post :reblog
          post :unreblog
          post :favourite
          post :unfavourite
        end
      end

      resources :follows,  only: [:create]
      resources :media,    only: [:create]
      resources :apps,     only: [:create]

      resources :accounts, only: [:show] do
        collection do
          get :relationships
          get :verify_credentials
          get :suggestions
        end

        member do
          get :statuses
          get :followers
          get :following
          get :common_followers

          post :follow
          post :unfollow
          post :block
          post :unblock
        end
      end
    end
  end

  get :about, to: 'about#index'
  get :terms, to: 'about#terms'

  root 'home#index'

  match '*unmatched_route', via: :all, to: 'application#raise_not_found'
end
