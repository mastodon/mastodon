# frozen_string_literal: true

module WellKnown
  class OauthMetadataController < ActionController::Base # rubocop:disable Rails/ApplicationController
    include CacheConcern

    # Prevent `active_model_serializer`'s `ActionController::Serialization` from calling `current_user`
    # and thus re-issuing session cookies
    serialization_scope nil

    def show
      expires_in 3.days, public: true
      render_with_cache json: ::OauthMetadataPresenter.new, serializer: ::OauthMetadataSerializer, content_type: 'application/json'
    end
  end
end
