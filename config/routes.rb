# frozen_string_literal: true

require 'sidekiq_unique_jobs/web'
require 'sidekiq-scheduler/web'

#for dashboard:
require 'sidekiq/web'

Rails.application.routes.draw do
  # Mount the Sidekiq Web UI at /sidekiq
  mount Sidekiq::Web => '/sidekiq'
  # Paths of routes on the web app that to not require to be indexed or
  # have alternative format representations requiring separate controllers
  web_app_paths = %w(
    /getting-started
    /keyboard-shortcuts
    /home
    /public
    /public/local
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

    namespace :auth do
      resource :setup, only: [:show, :update], controller: :setup
      resource :challenge, only: [:create], controller: :challenges
      get 'sessions/security_key_options', to: 'sessions#webauthn_options'
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
    resource :follow, only: [:create], controller: :account_follow
    resource :unfollow, only: [:create], controller: :account_unfollow

    resource :outbox, only: [:show], module: :activitypub
    resource :inbox, only: [:create], module: :activitypub
    resource :claim, only: [:create], module: :activitypub
    resources :collections, only: [:show], module: :activitypub
    resource :followers_synchronization, only: [:show], module: :activitypub
  end

  resource :inbox, only: [:create], module: :activitypub

  constraints(username: /[^@\/.]+/) do
    get '/@:username', to: 'accounts#show', as: :short_account
    get '/@:username/with_replies', to: 'accounts#show', as: :short_account_with_replies
    get '/@:username/media', to: 'accounts#show', as: :short_account_media
    get '/@:username/tagged/:tag', to: 'accounts#show', as: :short_account_tag
  end

  constraints(account_username: /[^@\/.]+/) do
    get '/@:account_username/following', to: 'following_accounts#index'
    get '/@:account_username/followers', to: 'follower_accounts#index'
    get '/@:account_username/:id', to: 'statuses#show', as: :short_account_status
    get '/@:account_username/:id/embed', to: 'statuses#embed', as: :embed_short_account_status
  end

  get '/@:username_with_domain/(*any)', to: 'home#index', constraints: { username_with_domain: /([^\/])+?/ }, format: false
  get '/settings', to: redirect('/settings/profile')

  namespace :settings do
    resource :profile, only: [:show, :update] do
      resources :pictures, only: :destroy
    end

    get :preferences, to: redirect('/settings/preferences/appearance')

    namespace :preferences do
      resource :appearance, only: [:show, :update], controller: :appearance
      resource :notifications, only: [:show, :update]
      resource :other, only: [:show, :update], controller: :other
    end

    resource :import, only: [:show, :create]
    resource :export, only: [:show, :create]

    namespace :exports, constraints: { format: :csv } do
      resources :follows, only: :index, controller: :following_accounts
      resources :blocks, only: :index, controller: :blocked_accounts
      resources :mutes, only: :index, controller: :muted_accounts
      resources :lists, only: :index, controller: :lists
      resources :domain_blocks, only: :index, controller: :blocked_domains
      resources :bookmarks, only: :index, controller: :bookmarks
    end

    resources :two_factor_authentication_methods, only: [:index] do
      collection do
        post :disable
      end
    end

    resource :otp_authentication, only: [:show, :create], controller: 'two_factor_authentication/otp_authentication'

    resources :webauthn_credentials, only: [:index, :new, :create, :destroy],
              path: 'security_keys',
              controller: 'two_factor_authentication/webauthn_credentials' do

      collection do
        get :options
      end
    end

    namespace :two_factor_authentication do
      resources :recovery_codes, only: [:create]
      resource :confirmation, only: [:new, :create]
    end

    resources :applications, except: [:edit] do
      member do
        post :regenerate
      end
    end

    resource :delete, only: [:show, :destroy]
    resource :migration, only: [:show, :create]

    namespace :migration do
      resource :redirect, only: [:new, :create, :destroy]
    end

    resources :aliases, only: [:index, :create, :destroy]
    resources :sessions, only: [:destroy]
    resources :featured_tags, only: [:index, :create, :destroy]
    resources :login_activities, only: [:index]
  end

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

  resource :authorize_interaction, only: [:show, :create]
  resource :share, only: [:show, :create]

  namespace :admin do
    get '/dashboard', to: 'dashboard#index'

    resources :domain_allows, only: [:new, :create, :show, :destroy]
    resources :domain_blocks, only: [:new, :create, :show, :destroy, :update, :edit] do
      collection do
        post :batch
      end
    end

    resources :export_domain_allows, only: [:new] do
      collection do
        get :export, constraints: { format: :csv }
        post :import
      end
    end

    resources :export_domain_blocks, only: [:new] do
      collection do
        get :export, constraints: { format: :csv }
        post :import
      end
    end

    resources :email_domain_blocks, only: [:index, :new, :create] do
      collection do
        post :batch
      end
    end

    resources :action_logs, only: [:index]
    resources :warning_presets, except: [:new]

    resources :announcements, except: [:show] do
      member do
        post :publish
        post :unpublish
      end
    end

    get '/settings', to: redirect('/admin/settings/branding')
    get '/settings/edit', to: redirect('/admin/settings/branding')

    namespace :settings do
      resource :branding, only: [:show, :update], controller: 'branding'
      resource :registrations, only: [:show, :update], controller: 'registrations'
      resource :content_retention, only: [:show, :update], controller: 'content_retention'
      resource :about, only: [:show, :update], controller: 'about'
      resource :appearance, only: [:show, :update], controller: 'appearance'
      resource :discovery, only: [:show, :update], controller: 'discovery'
    end

    resources :site_uploads, only: [:destroy]

    resources :invites, only: [:index, :create, :destroy] do
      collection do
        post :deactivate_all
      end
    end

    resources :relays, only: [:index, :new, :create, :destroy] do
      member do
        post :enable
        post :disable
      end
    end

    resources :instances, only: [:index, :show, :destroy], constraints: { id: /[^\/]+/ } do
      member do
        post :clear_delivery_errors
        post :restart_delivery
        post :stop_delivery
      end
    end

    resources :rules

    resources :webhooks do
      member do
        post :enable
        post :disable
      end

      resource :secret, only: [], controller: 'webhooks/secrets' do
        post :rotate
      end
    end

    resources :reports, only: [:index, :show] do
      resources :actions, only: [:create], controller: 'reports/actions' do
        collection do
          post :preview
        end
      end

      member do
        post :assign_to_self
        post :unassign
        post :reopen
        post :resolve
      end
    end

    resources :report_notes, only: [:create, :destroy]

    resources :accounts, only: [:index, :show, :destroy] do
      member do
        post :enable
        post :unsensitive
        post :unsilence
        post :unsuspend
        post :redownload
        post :remove_avatar
        post :remove_header
        post :memorialize
        post :approve
        post :reject
        post :unblock_email
      end

      collection do
        post :batch
      end

      resource :change_email, only: [:show, :update]
      resource :reset, only: [:create]
      resource :action, only: [:new, :create], controller: 'account_actions'

      resources :statuses, only: [:index, :show] do
        collection do
          post :batch
        end
      end

      resources :relationships, only: [:index]

      resource :confirmation, only: [:create] do
        collection do
          post :resend
        end
      end
    end

    resources :users, only: [] do
      resource :two_factor_authentication, only: [:destroy], controller: 'users/two_factor_authentications'
      resource :role, only: [:show, :update], controller: 'users/roles'
    end

    resources :custom_emojis, only: [:index, :new, :create] do
      collection do
        post :batch
      end
    end

    resources :ip_blocks, only: [:index, :new, :create] do
      collection do
        post :batch
      end
    end

    resources :roles, except: [:show]
    resources :account_moderation_notes, only: [:create, :destroy]
    resource :follow_recommendations, only: [:show, :update]
    resources :tags, only: [:show, :update]

    namespace :trends do
      resources :links, only: [:index] do
        collection do
          post :batch
        end
      end

      resources :tags, only: [:index] do
        collection do
          post :batch
        end
      end

      resources :statuses, only: [:index] do
        collection do
          post :batch
        end
      end

      namespace :links do
        resources :preview_card_providers, only: [:index], path: :publishers do
          collection do
            post :batch
          end
        end
      end
    end

    namespace :disputes do
      resources :appeals, only: [:index] do
        member do
          post :approve
          post :reject
        end
      end
    end
  end

  get '/admin', to: redirect('/admin/dashboard', status: 302)

  namespace :api, format: false do
    # OEmbed
    get '/oembed', to: 'oembed#show', as: :oembed

    # JSON / REST API
    namespace :v1 do
      resources :statuses, only: [:create, :show, :update, :destroy] do
        scope module: :statuses do
          resources :reblogged_by, controller: :reblogged_by_accounts, only: :index
          resources :favourited_by, controller: :favourited_by_accounts, only: :index
          resource :reblog, only: :create
          post :unreblog, to: 'reblogs#destroy'

          resource :favourite, only: :create
          post :unfavourite, to: 'favourites#destroy'

          resource :bookmark, only: :create
          post :unbookmark, to: 'bookmarks#destroy'

          resource :mute, only: :create
          post :unmute, to: 'mutes#destroy'

          resource :pin, only: :create
          post :unpin, to: 'pins#destroy'

          resource :history, only: :show
          resource :source, only: :show

          post :translate, to: 'translations#create'
        end

        member do
          get :context
        end
      end

      namespace :timelines do
        resource :home, only: :show, controller: :home
        resource :public, only: :show, controller: :public
        resources :tag, only: :show
        resources :list, only: :show
        resource :regenerate, only: :create, controller: :regenerate
        resource :add_to_feed, only: :create, controller: :add_to_feed
        resource :clean_feeds, only: :create, controller: :clean_feeds
        resource :remove_from_feed, only: :create, controller: :remove_from_feed
      end

      resources :streaming, only: [:index]
      resources :custom_emojis, only: [:index]
      resources :suggestions, only: [:index, :destroy]
      resources :scheduled_statuses, only: [:index, :show, :update, :destroy]
      resources :preferences, only: [:index]

      resources :announcements, only: [:index] do
        scope module: :announcements do
          resources :reactions, only: [:update, :destroy]
        end

        member do
          post :dismiss
        end
      end

      # namespace :crypto do
      #   resources :deliveries, only: :create

      #   namespace :keys do
      #     resource :upload, only: [:create]
      #     resource :query,  only: [:create]
      #     resource :claim,  only: [:create]
      #     resource :count,  only: [:show]
      #   end

      #   resources :encrypted_messages, only: [:index] do
      #     collection do
      #       post :clear
      #     end
      #   end
      # end

      resources :conversations, only: [:index, :destroy] do
        member do
          post :read
        end
      end

      resources :media,        only: [:create, :update, :show]
      resources :blocks,       only: [:index]
      resources :mutes,        only: [:index]
      resources :favourites,   only: [:index]
      resources :bookmarks,    only: [:index]
      resources :reports,      only: [:create]
      resources :trends,       only: [:index], controller: 'trends/tags'
      resources :filters,      only: [:index, :create, :show, :update, :destroy]
      resources :endorsements, only: [:index]
      resources :markers,      only: [:index, :create]

      namespace :apps do
        get :verify_credentials, to: 'credentials#show'
      end

      resources :apps, only: [:create]

      namespace :trends do
        resources :links, only: [:index]
        resources :tags, only: [:index]
        resources :statuses, only: [:index]
      end

      namespace :emails do
        resources :confirmations, only: [:create]
      end

      resource :instance, only: [:show] do
        resources :peers, only: [:index], controller: 'instances/peers'
        resources :rules, only: [:index], controller: 'instances/rules'
        resources :domain_blocks, only: [:index], controller: 'instances/domain_blocks'
        resource :privacy_policy, only: [:show], controller: 'instances/privacy_policies'
        resource :extended_description, only: [:show], controller: 'instances/extended_descriptions'
        resource :activity, only: [:show], controller: 'instances/activity'
      end

      resource :domain_blocks, only: [:show, :create, :destroy]

      resource :directory, only: [:show]

      resources :follow_requests, only: [:index] do
        member do
          post :authorize
          post :reject
        end
      end

      resources :notifications, only: [:index, :show] do
        collection do
          post :clear
        end

        member do
          post :dismiss
        end
      end

      namespace :accounts do
        get :verify_credentials, to: 'credentials#show'
        patch :update_credentials, to: 'credentials#update'
        resource :search, only: :show, controller: :search
        resource :lookup, only: :show, controller: :lookup
        resources :relationships, only: :index
        resources :familiar_followers, only: :index
      end

      resources :accounts, only: [:create, :show] do
        resources :statuses, only: :index, controller: 'accounts/statuses'
        resources :followers, only: :index, controller: 'accounts/follower_accounts'
        resources :following, only: :index, controller: 'accounts/following_accounts'
        resources :lists, only: :index, controller: 'accounts/lists'
        resources :identity_proofs, only: :index, controller: 'accounts/identity_proofs'
        resources :featured_tags, only: :index, controller: 'accounts/featured_tags'

        member do
          post :follow
          post :unfollow
          post :remove_from_followers
          post :block
          post :unblock
          post :mute
          post :unmute
        end

        resource :pin, only: :create, controller: 'accounts/pins'
        post :unpin, to: 'accounts/pins#destroy'
        resource :note, only: :create, controller: 'accounts/notes'
      end

      resources :tags, only: [:show] do
        member do
          post :follow
          post :unfollow
        end
      end

      resources :followed_tags, only: [:index]

      resources :lists, only: [:index, :create, :show, :update, :destroy] do
        resource :accounts, only: [:show, :create, :destroy], controller: 'lists/accounts'
      end

      namespace :featured_tags do
        get :suggestions, to: 'suggestions#index'
      end

      resources :featured_tags, only: [:index, :create, :destroy]

      resources :polls, only: [:create, :show] do
        resources :votes, only: :create, controller: 'polls/votes'
      end

      namespace :push do
        resource :subscription, only: [:create, :show, :update, :destroy]
      end

      namespace :admin do
        resources :accounts, only: [:index, :show, :destroy] do
          member do
            post :enable
            post :unsensitive
            post :unsilence
            post :unsuspend
            post :approve
            post :reject
          end

          resource :action, only: [:create], controller: 'account_actions'
        end

        resources :reports, only: [:index, :update, :show] do
          member do
            post :assign_to_self
            post :unassign
            post :reopen
            post :resolve
          end
        end

        resources :domain_allows, only: [:index, :show, :create, :destroy]
        resources :domain_blocks, only: [:index, :show, :update, :create, :destroy]
        resources :email_domain_blocks, only: [:index, :show, :create, :destroy]
        resources :ip_blocks, only: [:index, :show, :update, :create, :destroy]

        namespace :trends do
          resources :tags, only: [:index]
          resources :links, only: [:index]
          resources :statuses, only: [:index]
        end

        post :measures, to: 'measures#create'
        post :dimensions, to: 'dimensions#create'
        post :retention, to: 'retention#create'

        resources :canonical_email_blocks, only: [:index, :create, :show, :destroy] do
          collection do
            post :test
          end
        end
      end
    end

    namespace :v2 do
      get '/search', to: 'search#index', as: :search

      resources :media,       only: [:create]
      resources :suggestions, only: [:index]
      resource  :instance,    only: [:show]
      resources :filters,     only: [:index, :create, :show, :update, :destroy] do
        resources :keywords, only: [:index, :create], controller: 'filters/keywords'
        resources :statuses, only: [:index, :create], controller: 'filters/statuses'
      end

      namespace :filters do
        resources :keywords, only: [:show, :update, :destroy]
        resources :statuses, only: [:show, :destroy]
      end

      namespace :admin do
        resources :accounts, only: [:index]
      end
    end

    namespace :web do
      resource :settings, only: [:update]
      resource :embed, only: [:create]
      resources :push_subscriptions, only: [:create] do
        member do
          put :update
        end
      end
    end
  end

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
