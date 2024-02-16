# frozen_string_literal: true

module WellKnown
  class OauthMetadataController < ActionController::Base # rubocop:disable Rails/ApplicationController
    include CacheConcern

    def show
      expires_in 3.days, public: true
      render_with_cache json: ::OauthMetadataPresenter.new, serializer: ::OauthMetadataSerializer, content_type: 'application/json', public: true
    end
  end
end
