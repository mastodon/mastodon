# frozen_string_literal: true

module WellKnown
  class HostMetaController < ActionController::Base # rubocop:disable Rails/ApplicationController
    include RoutingHelper

    def show
      @webfinger_template = "#{webfinger_url}?resource={uri}"
      expires_in 3.days, public: true

      respond_to do |format|
        format.any do
          render content_type: 'application/xrd+xml', formats: [:xml]
        end

        format.json
      end
    end
  end
end
