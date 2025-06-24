# frozen_string_literal: true

class OAuth::Application < ApplicationRecord
  include ::Doorkeeper::Orm::ActiveRecord::Mixins::Application

  APP_NAME_LIMIT = 60
  APP_REDIRECT_URI_LIMIT = 2_000
  APP_WEBSITE_LIMIT = 2_000

  include Redisable

  has_many :created_users, class_name: 'User', foreign_key: :created_by_application_id, inverse_of: :created_by_application, dependent: nil

  validates :name, length: { maximum: APP_NAME_LIMIT }
  validates :redirect_uri, length: { maximum: APP_REDIRECT_URI_LIMIT }
  validates :website, url: true, length: { maximum: APP_WEBSITE_LIMIT }, if: :website?

  before_destroy :close_streaming_sessions, prepend: true

  def confirmation_redirect_uri
    redirect_uri.lines.first.strip
  end

  def redirect_uris
    # The redirect_uri value is stored as a newline delimited list
    redirect_uri.split
  end

  # The association between `Application` and `AccessToken` uses a setting of
  # `dependent: delete_all` which means the callbacks in `AccessToken` are not
  # run. Instead, announce to streaming that these tokens are being deleted.
  def close_streaming_sessions(resource_owner = nil)
    payload = Oj.dump(event: :kill)
    scope = access_tokens
    scope = scope.where(resource_owner_id: resource_owner.id) unless resource_owner.nil?
    scope.in_batches do |tokens|
      redis.pipelined do |pipeline|
        tokens.ids.each do |id|
          pipeline.publish("timeline:access_token:#{id}", payload)
        end
      end
    end
  end
end
