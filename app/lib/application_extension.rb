# frozen_string_literal: true

module ApplicationExtension
  extend ActiveSupport::Concern

  included do
    include Redisable

    has_many :created_users, class_name: 'User', foreign_key: 'created_by_application_id', inverse_of: :created_by_application

    validates :name, length: { maximum: 60 }
    validates :website, url: true, length: { maximum: 2_000 }, if: :website?
    validates :redirect_uri, length: { maximum: 2_000 }

    # The relationship used between Applications and AccessTokens is using
    # dependent: delete_all, which means the ActiveRecord callback in
    # AccessTokenExtension is not run, so instead we manually announce to
    # streaming that these tokens are being deleted.
    before_destroy :close_streaming_sessions, prepend: true
  end

  def confirmation_redirect_uri
    redirect_uri.lines.first.strip
  end

  def redirect_uris
    # Doorkeeper stores the redirect_uri value as a newline delimeted list in
    # the database:
    redirect_uri.split
  end

  def close_streaming_sessions(resource_owner = nil)
    # TODO: #28793 Combine into a single topic
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
