# frozen_string_literal: true

module WellKnown
  class HostMetaController < BaseController
    def show
      @webfinger_template = "#{webfinger_url}?resource={uri}"
      expires_in LONG_DURATION, public: true
      render content_type: 'application/xrd+xml', formats: [:xml]
    end
  end
end
