module Mastodon
  class Rest < Grape::API
    version 'v1', using: :path
    format :json

    resource :statuses do
      desc 'Return a public timeline'

      get :all do
        present Status.all, with: Mastodon::Entities::Status
      end

      desc 'Return the home timeline of a logged in user'

      get :home do
        # todo
      end

      desc 'Return the notifications timeline of a logged in user'

      get :notifications do
        # todo
      end
    end

    resource :accounts do
      desc 'Return a user profile'

      params do
        requires :id, type: String, desc: 'Account ID'
      end

      get ':id' do
        present Account.find(params[:id]), with: Mastodon::Entities::Account
      end
    end
  end
end
