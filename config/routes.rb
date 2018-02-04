# frozen_string_literal: true

require 'sidekiq/web'
require 'sidekiq-scheduler/web'

Sidekiq::Web.set :session_secret, Rails.application.secrets[:secret_key_base]

Rails.application.routes.draw do
  mount LetterOpenerWeb::Engine, at: 'letter_opener' if Rails.env.development?

  authenticate :user, lambda { |u| u.admin? } do
    mount Sidekiq::Web, at: 'sidekiq', as: :sidekiq
    mount PgHero::Engine, at: 'pghero', as: :pghero
  end

  use_doorkeeper do
    controllers authorizations: 'oauth/authorizations', authorized_applications: 'oauth/authorized_applications'
  end

  get '.well-known/host-meta', to: 'well_known/host_meta#show', as: :host_meta, defaults: { format: 'xml' }
  get '.well-known/webfinger', to: 'well_known/webfinger#show', as: :webfinger
  get 'manifest', to: 'manifests#show', defaults: { format: 'json' }

  devise_for :users, path: 'auth', controllers: {
    sessions:           'auth/sessions',
    registrations:      'auth/registrations',
    passwords:          'auth/passwords',
    confirmations:      'auth/confirmations',
  }

  get '/users/:username', to: redirect('/@%{username}'), constraints: lambda { |req| req.format.nil? || req.format.html? }

  resources :accounts, path: 'users', only: [:show], param: :username do
    resources :stream_entries, path: 'updates', only: [:show] do
      member do
        get :embed
      end
    end

    get :remote_follow,  to: 'remote_follow#new'
    post :remote_follow, to: 'remote_follow#create'

    resources :statuses, only: [:show] do
      member do
        get :activity
      end
    end

    resources :followers, only: [:index], controller: :follower_accounts
    resources :following, only: [:index], controller: :following_accounts
    resource :follow, only: [:create], controller: :account_follow
    resource :unfollow, only: [:create], controller: :account_unfollow
    resource :outbox, only: [:show], module: :activitypub
  end

  get '/@:username', to: 'accounts#show', as: :short_account
  get '/@:account_username/:id', to: 'statuses#show', as: :short_account_status

  namespace :settings do
    resource :profile, only: [:show, :update]
    resource :preferences, only: [:show, :update]
    resource :import, only: [:show, :create]

    resource :export, only: [:show]
    namespace :exports, constraints: { format: :csv } do
      resources :follows, only: :index, controller: :following_accounts
      resources :blocks, only: :index, controller: :blocked_accounts
      resources :mutes, only: :index, controller: :muted_accounts
    end

    resource :two_factor_authentication, only: [:show, :create, :destroy]
    namespace :two_factor_authentication do
      resources :recovery_codes, only: [:create]
      resource :confirmation, only: [:new, :create]
    end

    resource :follower_domains, only: [:show, :update]
    resource :delete, only: [:show, :destroy]

    resources :sessions, only: [:destroy]
  end

  resources :media, only: [:show]
  resources :tags,  only: [:show]

  # Remote follow
  resource :authorize_follow, only: [:show, :create]

  namespace :admin do
    resources :subscriptions, only: [:index]
    resources :domain_blocks, only: [:index, :new, :create, :show, :destroy]
    resource :settings, only: [:edit, :update]
    
    resources :instances, only: [:index] do
      collection do
        post :resubscribe
      end
    end

    resources :reports, only: [:index, :show, :update] do
      resources :reported_statuses, only: [:create, :update, :destroy]
    end

    resources :accounts, only: [:index, :show] do
      member do
        post :subscribe
        post :unsubscribe
        post :redownload
      end

      resource :reset, only: [:create]
      resource :silence, only: [:create, :destroy]
      resource :suspension, only: [:create, :destroy]
      resource :confirmation, only: [:create]
      resources :statuses, only: [:index, :create, :update, :destroy]
    end

    resources :users, only: [] do
      resource :two_factor_authentication, only: [:destroy]
    end
  end

  get '/admin', to: redirect('/admin/settings/edit', status: 302)

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
        scope module: :statuses do
          resources :reblogged_by, controller: :reblogged_by_accounts, only: :index
          resources :favourited_by, controller: :favourited_by_accounts, only: :index
          resource :reblog, only: :create
          post :unreblog, to: 'reblogs#destroy'

          resource :favourite, only: :create
          post :unfavourite, to: 'favourites#destroy'

          resource :mute, only: :create
          post :unmute, to: 'mutes#destroy'
        end

        member do
          get :context
          get :card
        end
      end

      namespace :timelines do
        resource :home, only: :show, controller: :home
        resource :public, only: :show, controller: :public
        resources :tag, only: :show
      end
      resources :streaming,  only: [:index]

      get '/search', to: 'search#index', as: :search

      resources :follows,    only: [:create]
      resources :media,      only: [:create]
      resources :apps,       only: [:create]
      resources :blocks,     only: [:index]
      resources :mutes,      only: [:index]
      resources :favourites, only: [:index]
      resources :reports,    only: [:index, :create]

      resource :instance,      only: [:show]
      resource :domain_blocks, only: [:show, :create, :destroy]

      resources :follow_requests, only: [:index] do
        member do
          post :authorize
          post :reject
        end
      end

      resources :notifications, only: [:index, :show] do
        collection do
          post :clear
          post :dismiss
        end
      end

      namespace :accounts do
        get :verify_credentials, to: 'credentials#show'
        patch :update_credentials, to: 'credentials#update'
        resource :search, only: :show, controller: :search
        resources :relationships, only: :index
      end
      resources :accounts, only: [:show] do
        resources :statuses, only: :index, controller: 'accounts/statuses'
        resources :followers, only: :index, controller: 'accounts/follower_accounts'
        resources :following, only: :index, controller: 'accounts/following_accounts'

        member do
          post :follow
          post :unfollow
          post :block
          post :unblock
          post :mute
          post :unmute
        end
      end
    end

    namespace :web do
      resource :settings, only: [:update]
      resources :push_subscriptions, only: [:create] do
        member do
          put :update
        end
      end
    end
  end

  get '/web/(*any)', to: 'home#index', as: :web

  get '/about',      to: 'about#show'
  get '/about/more', to: 'about#more'
  get '/terms',      to: 'about#terms'

  root 'home#index'

  match '*unmatched_route',
    via: :all,
    to: 'application#raise_not_found',
    format: false
end
