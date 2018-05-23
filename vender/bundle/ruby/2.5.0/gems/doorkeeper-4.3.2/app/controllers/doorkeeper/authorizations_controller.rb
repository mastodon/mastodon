module Doorkeeper
  class AuthorizationsController < Doorkeeper::ApplicationController
    before_action :authenticate_resource_owner!

    def new
      if pre_auth.authorizable?
        if skip_authorization? || matching_token?
          auth = authorization.authorize
          redirect_to auth.redirect_uri
        else
          render :new
        end
      else
        render :error
      end
    end

    # TODO: Handle raise invalid authorization
    def create
      redirect_or_render authorization.authorize
    end

    def destroy
      redirect_or_render authorization.deny
    end

    private

    def matching_token?
      AccessToken.matching_token_for pre_auth.client,
                                     current_resource_owner.id,
                                     pre_auth.scopes
    end

    def redirect_or_render(auth)
      if auth.redirectable?
        redirect_to auth.redirect_uri
      else
        render json: auth.body, status: auth.status
      end
    end

    def pre_auth
      @pre_auth ||= OAuth::PreAuthorization.new(Doorkeeper.configuration,
                                                server.client_via_uid,
                                                params)
    end

    def authorization
      @authorization ||= strategy.request
    end

    def strategy
      @strategy ||= server.authorization_request pre_auth.response_type
    end
  end
end
