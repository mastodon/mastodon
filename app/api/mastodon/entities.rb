module Mastodon
  module Entities
    class Account < Grape::Entity
      expose :username
      expose :domain
    end

    class Status < Grape::Entity
      format_with(:iso_timestamp) { |dt| dt.iso8601 }

      expose :uri
      expose :text
      expose :account, using: Mastodon::Entities::Account

      with_options(format_with: :iso_timestamp) do
        expose :created_at
        expose :updated_at
      end
    end
  end
end
