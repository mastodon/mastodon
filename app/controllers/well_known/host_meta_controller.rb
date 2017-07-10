# frozen_string_literal: true

module WellKnown
  class HostMetaController < ApplicationController
    include RoutingHelper

    def show
      @webfinger_template = "#{webfinger_url}?resource={uri}"

      respond_to do |format|
        format.xml { render content_type: 'application/xrd+xml' }
      end
    end
  end
end
