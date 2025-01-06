# frozen_string_literal: true

namespace :api, format: false do
  namespace :fasp do
    namespace :debug do
      namespace :v0 do
        namespace :callback do
          resources :responses, only: [:create]
        end
      end
    end

    namespace :data_sharing do
      namespace :v0 do
        resources :backfill_requests, only: [:create] do
          resource :continuation, only: [:create]
        end

        resources :event_subscriptions, only: [:create, :destroy]
      end
    end

    resource :registration, only: [:create]
  end
end

namespace :admin do
  namespace :fasp do
    namespace :debug do
      resources :callbacks, only: [:index, :destroy]
    end

    resources :providers, only: [:index, :show, :edit, :update, :destroy] do
      resources :debug_calls, only: [:create]

      resource :registration, only: [:new, :create]
    end
  end
end
