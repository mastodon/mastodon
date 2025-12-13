# frozen_string_literal: true

module WellKnown
  class OAuthMetadataController < ActionController::Base # rubocop:disable Rails/ApplicationController
    include CacheConcern

    # Prevent `active_model_serializer`'s `ActionController::Serialization` from calling `current_user`
    # and thus re-issuing session cookies
    serialization_scope nil

    def show
      # Due to this document potentially changing between Mastodon versions (as
      # new OAuth scopes are added), we don't use expires_in to cache upstream,
      # instead just caching in the rails cache:
      render_with_cache(
        json: ::OAuthMetadataPresenter.new,
        serializer: ::OAuthMetadataSerializer,
        content_type: 'application/json',
        expires_in: 15.minutes
      )
    end
  end
end
