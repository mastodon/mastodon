# frozen_string_literal: true

require 'sidekiq_unique_jobs/web' if ENV['ENABLE_SIDEKIQ_UNIQUE_JOBS_UI'] == true
require 'sidekiq-scheduler/web'

class RedirectWithVary < ActionDispatch::Routing::PathRedirect
  def build_response(req)
    super.tap do |response|
      response.headers['Vary'] = 'Origin, Accept'
    end
  end
end

def redirect_with_vary(path)
  RedirectWithVary.new(301, path)
end

Rails.application.routes.draw do
  root 'home#index'

  mount LetterOpenerWeb::Engine, at: 'letter_opener' if Rails.env.development?

  get 'health', to: 'health#show'

  authenticate :user, ->(user) { user.role&.can?(:view_devops) } do
    mount Sidekiq::Web, at: 'sidekiq', as: :sidekiq
    mount PgHero::Engine, at: 'pghero', as: :pghero
  end

  use_doorkeeper do
    controllers authorizations: 'oauth/authorizations',
                authorized_applications: 'oauth/authorized_applications',
                tokens: 'oauth/tokens'
  end

  namespace :oauth do
    # As this is borrowed from OpenID, the specification says we must also support
    # POST for the userinfo endpoint:
    # https://openid.net/specs/openid-connect-core-1_0.html#UserInfo
    match 'userinfo', via: [:get, :post], to: 'userinfo#show', defaults: { format: 'json' }
  end

  scope path: '.well-known' do
    scope module: :well_known do
      get 'oauth-authorization-server', to: 'oauth_metadata#show', as: :oauth_metadata, defaults: { format: 'json' }
      get 'host-meta', to: 'host_meta#show', as: :host_meta
      get 'nodeinfo', to: 'node_info#index', as: :nodeinfo, defaults: { format: 'json' }
      get 'webfinger', to: 'webfinger#show', as: :webfinger
    end
    get 'change-password', to: redirect('/auth/edit'), as: nil
    get 'proxy', to: redirect { |_, request| "/authorize_interaction?#{request.params.to_query}" }, as: nil
  end

  get '/nodeinfo/2.0', to: 'well_known/node_info#show', as: :nodeinfo_schema

  get 'manifest', to: 'manifests#show', defaults: { format: 'json' }
  get 'intent', to: 'intents#show'
  get 'custom.css', to: 'custom_css#show'
  resources :custom_css, only: :show, path: :css

  get 'remote_interaction_helper', to: 'remote_interaction_helper#index'

  resource :instance_actor, path: 'actor', only: [:show] do
    scope module: :activitypub do
      resource :inbox, only: [:create]
      resource :outbox, only: [:show]
    end
  end

  get '/invite/:invite_code', constraints: ->(req) { req.format == :json }, to: 'api/v1/invites#show'

  devise_scope :user do
    get '/invite/:invite_code', to: 'auth/registrations#new', as: :public_invite

    resource :unsubscribe, only: [:show, :create], controller: :mail_subscriptions

    namespace :auth do
      resource :setup, only: [:show, :update], controller: :setup
      resource :challenge, only: [:create]
      get 'sessions/security_key_options', to: 'sessions#webauthn_options'
      post 'captcha_confirmation', to: 'confirmations#confirm_captcha', as: :captcha_confirmation
    end
  end

  scope module: :auth do
    devise_for :users, path: 'auth', format: false
  end

  with_options constraints: ->(req) { req.format.nil? || req.format.html? } do
    get '/users/:username', to: redirect_with_vary('/@%{username}')
    get '/users/:username/following', to: redirect_with_vary('/@%{username}/following')
    get '/users/:username/followers', to: redirect_with_vary('/@%{username}/followers')
    get '/users/:username/statuses/:id', to: redirect_with_vary('/@%{username}/%{id}')
  end

  get '/authorize_follow', to: redirect { |_, request| "/authorize_interaction?#{request.params.to_query}" }

  resources :accounts, path: 'users', only: [:show], param: :username do
    resources :statuses, only: [:show] do
      member do
        get :activity
        get :embed
      end

      resources :replies, only: [:index], module: :activitypub
      resources :likes, only: [:index], module: :activitypub
      resources :shares, only: [:index], module: :activitypub
    end

    resources :followers, only: [:index], controller: :follower_accounts
    resources :following, only: [:index], controller: :following_accounts

    scope module: :activitypub do
      resource :outbox, only: [:show]
      resource :inbox, only: [:create]
      resources :collections, only: [:show]
      resource :followers_synchronization, only: [:show]
    end
  end

  resource :inbox, only: [:create], module: :activitypub

  constraints(encoded_path: /%40.*/) do
    get '/:encoded_path', to: redirect { |params|
      "/#{params[:encoded_path].gsub('%40', '@')}"
    }
  end

  constraints(username: %r{[^@/.]+}) do
    with_options to: 'accounts#show' do
      get '/@:username', as: :short_account
      get '/@:username/with_replies', as: :short_account_with_replies
      get '/@:username/media', as: :short_account_media
      get '/@:username/tagged/:tag', as: :short_account_tag
    end
  end

  constraints(account_username: %r{[^@/.]+}) do
    get '/@:account_username/following', to: 'following_accounts#index'
    get '/@:account_username/followers', to: 'follower_accounts#index'
    get '/@:account_username/:id', to: 'statuses#show', as: :short_account_status
    get '/@:account_username/:id/embed', to: 'statuses#embed', as: :embed_short_account_status
  end

  get '/@:username_with_domain/(*any)', to: 'home#index', constraints: { username_with_domain: %r{([^/])+?} }, as: :account_with_domain, format: false
  get '/settings', to: redirect('/settings/profile')

  draw(:settings)

  namespace :disputes do
    resources :strikes, only: [:show, :index] do
      resource :appeal, only: [:create]
    end
  end

  namespace :redirect do
    resources :accounts, only: :show
    resources :statuses, only: :show
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
  resources :severed_relationships, only: [:index] do
    member do
      constraints(format: :csv) do
        get :followers
        get :following
      end
    end
  end
  resource :statuses_cleanup, controller: :statuses_cleanup, only: [:show, :update]

  get '/media_proxy/:id/(*any)', to: 'media_proxy#show', as: :media_proxy, format: false
  get '/backups/:id/download', to: 'backups#download', as: :download_backup, format: false

  resource :authorize_interaction, only: [:show]
  resource :share, only: [:show]

  draw(:admin)

  get '/admin', to: redirect('/admin/dashboard', status: 302)

  draw(:api)

  draw(:fasp)

  draw(:web_app)

  get '/web/(*any)', to: redirect('/%{any}', status: 302), as: :web, defaults: { any: '' }, format: false
  get '/about',      to: 'about#show'
  get '/about/more', to: redirect('/about')

  get '/privacy-policy',   to: 'privacy#show', as: :privacy_policy
  get '/terms-of-service', to: 'terms_of_service#show', as: :terms_of_service
  get '/terms',            to: redirect('/terms-of-service')

  match '/', via: [:post, :put, :patch, :delete], to: 'application#raise_not_found', format: false
  match '*unmatched_route', via: :all, to: 'application#raise_not_found', format: false
end
