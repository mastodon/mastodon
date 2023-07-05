# frozen_string_literal: true

require 'sidekiq_unique_jobs/web'
require 'sidekiq-scheduler/web'

Rails.application.routes.draw do
  # Paths of routes on the web app that to not require to be indexed or
  # have alternative format representations requiring separate controllers
  web_app_paths = %w(
    /getting-started
    /getting-started-misc
    /keyboard-shortcuts
    /home
    /public
    /public/local
    /public/remote
    /conversations
    /lists/(*any)
    /notifications
    /favourites
    /bookmarks
    /pinned
    /start
    /directory
    /explore/(*any)
    /search
    /publish
    /follow_requests
    /blocks
    /domain_blocks
    /mutes
    /followed_tags
    /statuses/(*any)
  ).freeze

  root 'home#index'

  mount LetterOpenerWeb::Engine, at: 'letter_opener' if Rails.env.development?

  get 'health', to: 'health#show'

  authenticate :user, lambda { |u| u.role&.can?(:view_devops) } do
    mount Sidekiq::Web, at: 'sidekiq', as: :sidekiq
    mount PgHero::Engine, at: 'pghero', as: :pghero
  end

  use_doorkeeper do
    controllers authorizations: 'oauth/authorizations',
                authorized_applications: 'oauth/authorized_applications',
                tokens: 'oauth/tokens'
  end

  get '.well-known/host-meta', to: 'well_known/host_meta#show', as: :host_meta, defaults: { format: 'xml' }
  get '.well-known/nodeinfo', to: 'well_known/nodeinfo#index', as: :nodeinfo, defaults: { format: 'json' }
  get '.well-known/webfinger', to: 'well_known/webfinger#show', as: :webfinger
  get '.well-known/change-password', to: redirect('/auth/edit')

  get '/nodeinfo/2.0', to: 'well_known/nodeinfo#show', as: :nodeinfo_schema

  get 'manifest', to: 'manifests#show', defaults: { format: 'json' }
  get 'intent', to: 'intents#show'
  get 'custom.css', to: 'custom_css#show', as: :custom_css

  resource :instance_actor, path: 'actor', only: [:show] do
    resource :inbox, only: [:create], module: :activitypub
    resource :outbox, only: [:show], module: :activitypub
  end

  devise_scope :user do
    get '/invite/:invite_code', to: 'auth/registrations#new', as: :public_invite

    resource :unsubscribe, only: [:show, :create], controller: :mail_subscriptions

    namespace :auth do
      resource :setup, only: [:show, :update], controller: :setup
      resource :challenge, only: [:create], controller: :challenges
      get 'sessions/security_key_options', to: 'sessions#webauthn_options'
      post 'captcha_confirmation', to: 'confirmations#confirm_captcha', as: :captcha_confirmation
    end
  end

  devise_for :users, path: 'auth', format: false, controllers: {
    omniauth_callbacks: 'auth/omniauth_callbacks',
    sessions:           'auth/sessions',
    registrations:      'auth/registrations',
    passwords:          'auth/passwords',
    confirmations:      'auth/confirmations',
  }

  get '/users/:username', to: redirect('/@%{username}'), constraints: lambda { |req| req.format.nil? || req.format.html? }
  get '/users/:username/following', to: redirect('/@%{username}/following'), constraints: lambda { |req| req.format.nil? || req.format.html? }
  get '/users/:username/followers', to: redirect('/@%{username}/followers'), constraints: lambda { |req| req.format.nil? || req.format.html? }
  get '/users/:username/statuses/:id', to: redirect('/@%{username}/%{id}'), constraints: lambda { |req| req.format.nil? || req.format.html? }
  get '/authorize_follow', to: redirect { |_, request| "/authorize_interaction?#{request.params.to_query}" }

  resources :accounts, path: 'users', only: [:show], param: :username do
    resources :statuses, only: [:show] do
      member do
        get :activity
        get :embed
      end

      resources :replies, only: [:index], module: :activitypub
    end

    resources :followers, only: [:index], controller: :follower_accounts
    resources :following, only: [:index], controller: :following_accounts

    resource :outbox, only: [:show], module: :activitypub
    resource :inbox, only: [:create], module: :activitypub
    resource :claim, only: [:create], module: :activitypub
    resources :collections, only: [:show], module: :activitypub
    resource :followers_synchronization, only: [:show], module: :activitypub
  end

  resource :inbox, only: [:create], module: :activitypub

  get '/:encoded_at(*path)', to: redirect("/@%{path}"), constraints: { encoded_at: /%40/ }

  constraints(username: %r{[^@/.]+}) do
    get '/@:username', to: 'accounts#show', as: :short_account
    get '/@:username/with_replies', to: 'accounts#show', as: :short_account_with_replies
    get '/@:username/media', to: 'accounts#show', as: :short_account_media
    get '/@:username/tagged/:tag', to: 'accounts#show', as: :short_account_tag
  end

  constraints(account_username: %r{[^@/.]+}) do
    get '/@:account_username/following', to: 'following_accounts#index'
    get '/@:account_username/followers', to: 'follower_accounts#index'
    get '/@:account_username/:id', to: 'statuses#show', as: :short_account_status
    get '/@:account_username/:id/embed', to: 'statuses#embed', as: :embed_short_account_status
  end

  get '/@:username_with_domain/(*any)', to: 'home#index', constraints: { username_with_domain: %r{([^/])+?} }, format: false
  get '/settings', to: redirect('/settings/profile')

  draw(:settings)

  namespace :disputes do
    resources :strikes, only: [:show, :index] do
      resource :appeal, only: [:create]
    end
  end

  resources :media, only: [:show] do
    get :player
  end

  resources :tags,   only: [:show]
  resources :emojis, only: [:show]
  resources :invites, only: [:index, :create, :destroy]
  resources :filters, except: [:show] do
    resources :statuses, only: [:index], controller: 'filters/statuses' do
      collection do
        post :batch
      end
    end
  end

  resource :relationships, only: [:show, :update]
  resource :statuses_cleanup, controller: :statuses_cleanup, only: [:show, :update]

  get '/media_proxy/:id/(*any)', to: 'media_proxy#show', as: :media_proxy, format: false
  get '/backups/:id/download', to: 'backups#download', as: :download_backup, format: false

  resource :authorize_interaction, only: [:show, :create]
  resource :share, only: [:show]

  draw(:admin)

  get '/admin', to: redirect('/admin/dashboard', status: 302)

  draw(:api)

  web_app_paths.each do |path|
    get path, to: 'home#index'
  end

  get '/web/(*any)', to: redirect('/%{any}', status: 302), as: :web, defaults: { any: '' }, format: false
  get '/about',      to: 'about#show'
  get '/about/more', to: redirect('/about')

  get '/privacy-policy', to: 'privacy#show', as: :privacy_policy
  get '/terms',          to: redirect('/privacy-policy')

  match '/', via: [:post, :put, :patch, :delete], to: 'application#raise_not_found', format: false
  match '*unmatched_route', via: :all, to: 'application#raise_not_found', format: false
end
