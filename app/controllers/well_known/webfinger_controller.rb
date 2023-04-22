# frozen_string_literal: true

module WellKnown
  class WebfingerController < ActionController::Base # rubocop:disable Rails/ApplicationController
    include RoutingHelper

    before_action :set_account
    before_action :check_account_suspension

    rescue_from ActiveRecord::RecordNotFound, with: :not_found
    rescue_from ActionController::ParameterMissing, WebfingerResource::InvalidRequest, with: :bad_request

    def show
      expires_in 3.days, public: true
      render json: @account, serializer: WebfingerSerializer, content_type: 'application/jrd+json'
    end

    private

    def set_account
      @account = Account.find_local!(username_from_resource)
    end

    def username_from_resource
      resource_user    = resource_param
      username, domain = resource_user.split('@')
      resource_user    = "#{username}@#{Rails.configuration.x.local_domain}" if Rails.configuration.x.alternate_domains.include?(domain)

      WebfingerResource.new(resource_user).username
    end

    def resource_param
      params.require(:resource)
    end

    def check_account_suspension
      gone if @account.suspended_permanently?
    end

    def gone
      expires_in(3.minutes, public: true)
      head 410
    end

    def bad_request
      expires_in(3.minutes, public: true)
      head 400
    end

    def not_found
      expires_in(3.minutes, public: true)
      head 404
    end
  end
end
