# frozen_string_literal: true

require 'sidekiq/web'

Rails.application.routes.draw do
  mount ActionCable.server, at: 'cable'

  authenticate :user, lambda { |u| u.admin? } do
    mount Sidekiq::Web, at: 'sidekiq', as: :sidekiq
    mount PgHero::Engine, at: 'pghero', as: :pghero
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
    confirmations:      'auth/confirmations',
  }

  resources :accounts, path: 'users', only: [:show], param: :username do
    resources :stream_entries, path: 'updates', only: [:show] do
      member do
        get :embed
      end
    end

    get :remote_follow,  to: 'remote_follow#new'
    post :remote_follow, to: 'remote_follow#create'

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

  # Remote follow
  get  :authorize_follow, to: 'authorize_follow#new'
  post :authorize_follow, to: 'authorize_follow#create'

  namespace :admin do
    resources :pubsubhubbub, only: [:index]
    resources :domain_blocks, only: [:index, :create]

    resources :accounts, only: [:index, :show, :update] do
      member do
        post :suspend
      end
    end
  end

  namespace :api do
    # PubSubHubbub outgoing subscriptions
    resources :subscriptions, only: [:show]
    post '/subscriptions/:id', to: 'subscriptions#update'

    # PubSubHubbub incoming subscriptions
    post '/push', to: 'push#update', as: :push

    # Salmon
    post '/salmon/:id', to: 'salmon#update', as: :salmon

    # OEmbed
    get '/oembed', to: 'oembed#show', as: :oembed

    # JSON / REST API
    namespace :v1 do
      resources :statuses, only: [:create, :show, :destroy] do
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

      get '/timelines/home',     to: 'timelines#home', as: :home_timeline
      get '/timelines/mentions', to: 'timelines#mentions', as: :mentions_timeline
      get '/timelines/public',   to: 'timelines#public', as: :public_timeline
      get '/timelines/tag/:id',  to: 'timelines#tag', as: :hashtag_timeline

      resources :follows,  only: [:create]
      resources :media,    only: [:create]
      resources :apps,     only: [:create]
      resources :blocks,   only: [:index]

      resources :follow_requests, only: [:index] do
        member do
          post :authorize
          post :reject
        end
      end

      resources :notifications, only: [:index]
      resources :favourites,    only: [:index]

      resources :accounts, only: [:show] do
        collection do
          get :relationships
          get :verify_credentials
          get :search
        end

        member do
          get :statuses
          get :followers
          get :following

          post :follow
          post :unfollow
          post :block
          post :unblock
        end
      end
    end

    namespace :web do
      resource :settings, only: [:update]
    end
  end

  get '/web/(*any)', to: 'home#index', as: :web

  get :about, to: 'about#index'
  get :terms, to: 'about#terms'

  root 'home#index'

  match '*unmatched_route', via: :all, to: 'application#raise_not_found'
end
