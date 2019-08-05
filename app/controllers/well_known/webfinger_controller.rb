# frozen_string_literal: true

module WellKnown
  class WebfingerController < ActionController::Base
    include RoutingHelper

    before_action { response.headers['Vary'] = 'Accept' }

    def show
      @account = Account.find_local!(username_from_resource)

      expires_in 3.days, public: true
      render json: @account, serializer: WebfingerSerializer, content_type: 'application/jrd+json'
    rescue ActiveRecord::RecordNotFound
      head 404
    end

    private

    def username_from_resource
      resource_user    = resource_param
      username, domain = resource_user.split('@')
      resource_user    = "#{username}@#{Rails.configuration.x.local_domain}" if Rails.configuration.x.alternate_domains.include?(domain)

      WebfingerResource.new(resource_user).username
    end

    def resource_param
      params.require(:resource)
    end
  end
end
