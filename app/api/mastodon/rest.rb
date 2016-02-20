module Mastodon
  class Rest < Grape::API
    version 'v1', using: :path
    format :json

    resource :statuses do
      desc 'Return a public timeline'
      get :all do
        present Status.all, with: Mastodon::Entities::Status
      end
    end
  end
end
