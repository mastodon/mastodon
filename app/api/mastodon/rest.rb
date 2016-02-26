module Mastodon
  class Rest < Grape::API
    version 'v1', using: :path
    format :json

    helpers do
      def current_user
        User.first
      end
    end

    resource :timelines do
      desc 'Return a public timeline'

      get :public do
        # todo
      end

      desc 'Return the home timeline of a logged in user'

      get :home do
        present current_user.timeline, with: Mastodon::Entities::StreamEntry
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
