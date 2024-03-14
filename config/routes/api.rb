# frozen_string_literal: true

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
      resource :direct, only: :show, controller: :direct
      resource :home, only: :show, controller: :home
      resource :public, only: :show, controller: :public
      resources :tag, only: :show
      resources :list, only: :show
    end

    get '/streaming', to: 'streaming#index'
    get '/streaming/(*any)', to: 'streaming#index'

    resources :custom_emojis, only: [:index]
    resources :suggestions, only: [:index, :destroy]
    resources :scheduled_statuses, only: [:index, :show, :update, :destroy]
    resources :preferences, only: [:index]

    resources :annual_reports, only: [:index] do
      member do
        post :read
      end
    end

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
        post :unread
      end
    end

    resources :media, only: [:create, :update, :show]
    resources :blocks, only: [:index]
    resources :mutes, only: [:index]
    resources :favourites, only: [:index]
    resources :bookmarks, only: [:index]
    resources :reports, only: [:create]
    resources :trends, only: [:index], controller: 'trends/tags'
    resources :filters, only: [:index, :create, :show, :update, :destroy]
    resources :endorsements, only: [:index]
    resources :markers, only: [:index, :create]

    namespace :profile do
      resource :avatar, only: :destroy
      resource :header, only: :destroy
    end

    namespace :apps do
      get :verify_credentials, to: 'credentials#show'
    end

    resources :apps, only: [:create]

    namespace :trends do
      resources :tags, only: [:index]
      resources :links, only: [:index]
      resources :statuses, only: [:index]
    end

    namespace :emails do
      resources :confirmations, only: [:create]
      get :check_confirmation, to: 'confirmations#check'
    end

    resource :instance, only: [:show] do
      scope module: :instances do
        resources :peers, only: [:index]
        resources :rules, only: [:index]
        resources :domain_blocks, only: [:index]
        resource :privacy_policy, only: [:show]
        resource :extended_description, only: [:show]
        resource :translation_languages, only: [:show]
        resource :languages, only: [:show]
        resource :activity, only: [:show], controller: :activity
      end
    end

    namespace :peers do
      get :search, to: 'search#index'
    end

    resource :domain_blocks, only: [:show, :create, :destroy]

    resource :directory, only: [:show]

    resources :follow_requests, only: [:index] do
      member do
        post :authorize
        post :reject
      end
    end

    namespace :notifications do
      resources :requests, only: [:index, :show] do
        member do
          post :accept
          post :dismiss
        end
      end

      resource :policy, only: [:show, :update]
    end

    resources :notifications, only: [:index, :show, :destroy] do
      collection do
        post :clear
        delete :destroy_multiple
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
      scope module: :accounts do
        resources :statuses, only: :index
        resources :followers, only: :index, controller: :follower_accounts
        resources :following, only: :index, controller: :following_accounts
        resources :lists, only: :index
        resources :identity_proofs, only: :index
        resources :featured_tags, only: :index
      end

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
        resources :tags, only: [:index] do
          member do
            post :approve
            post :reject
          end
        end
        resources :links, only: [:index] do
          member do
            post :approve
            post :reject
          end
        end
        resources :statuses, only: [:index] do
          member do
            post :approve
            post :reject
          end
        end

        namespace :links do
          resources :preview_card_providers, only: [:index], path: :publishers do
            member do
              post :approve
              post :reject
            end
          end
        end
      end

      post :measures, to: 'measures#create'
      post :dimensions, to: 'dimensions#create'
      post :retention, to: 'retention#create'

      resources :canonical_email_blocks, only: [:index, :create, :show, :destroy] do
        collection do
          post :test
        end
      end

      resources :tags, only: [:index, :show, :update]
    end
  end

  namespace :v2 do
    get '/search', to: 'search#index', as: :search

    resources :media, only: [:create]
    resources :suggestions, only: [:index]
    resource :instance, only: [:show]
    resources :filters, only: [:index, :create, :show, :update, :destroy] do
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
    resources :embeds, only: [:show]
    resources :push_subscriptions, only: [:create] do
      member do
        put :update
      end
    end
  end
end
