module Mastodon
  module Entities
    class Account < Grape::Entity
      include ApplicationHelper

      expose :id
      expose :username

      expose :domain do |account|
        account.local? ? LOCAL_DOMAIN : account.domain
      end

      expose :display_name
      expose :note

      expose :url do |account|
        account.local? ? profile_url(name: account.username) : account.url
      end
    end

    class Status < Grape::Entity
      include ApplicationHelper

      format_with(:iso_timestamp) { |dt| dt.iso8601 }

      expose :id

      expose :uri do |status|
        status.local? ? unique_tag(status.stream_entry.created_at, status.stream_entry.activity_id, status.stream_entry.activity_type) : status.uri
      end

      expose :url do |status|
        status.local? ? status_url(name: status.account.username, id: status.id) : status.url
      end

      expose :text
      expose :in_reply_to_id

      expose :reblog_of_id
      expose :reblog, using: Mastodon::Entities::Status

      expose :account, using: Mastodon::Entities::Account

      with_options(format_with: :iso_timestamp) do
        expose :created_at
        expose :updated_at
      end
    end

    class StreamEntry < Grape::Entity
      expose :activity, using: Mastodon::Entities::Status
    end
  end
end
