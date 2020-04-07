# frozen_string_literal: true

module WellKnown
  class HostMetaController < ActionController::Base
    protect_from_forgery with: :exception

    include RoutingHelper

    before_action { response.headers['Vary'] = 'Accept' }

    def show
      @webfinger_template = "#{webfinger_url}?resource={uri}"
      expires_in 3.days, public: true
      render content_type: 'application/xrd+xml', formats: [:xml]
    end
  end
end
