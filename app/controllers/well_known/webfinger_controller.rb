# frozen_string_literal: true

module WellKnown
  class WebfingerController < ActionController::Base
    include RoutingHelper

    before_action { response.headers['Vary'] = 'Accept' }

    def show
      @account = Account.find_local!(username_from_resource)

      respond_to do |format|
        format.any(:json, :html) do
          render json: @account, serializer: WebfingerSerializer, content_type: 'application/jrd+json'
        end

        format.xml do
          render content_type: 'application/xrd+xml'
        end
      end

      expires_in(3.days, public: true)
    rescue ActiveRecord::RecordNotFound
      head 404
    end

    private

    def username_from_resource
      resource_user = resource_param

      username, domain = resource_user.split('@')
      if Rails.configuration.x.alternate_domains.include?(domain)
        resource_user = "#{username}@#{Rails.configuration.x.local_domain}"
      end

      WebfingerResource.new(resource_user).username
    end

    def resource_param
      params.require(:resource)
    end
  end
end
