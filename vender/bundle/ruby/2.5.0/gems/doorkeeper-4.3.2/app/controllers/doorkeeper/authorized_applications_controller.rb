module Doorkeeper
  class AuthorizedApplicationsController < Doorkeeper::ApplicationController
    before_action :authenticate_resource_owner!

    def index
      @applications = Application.authorized_for(current_resource_owner)
    end

    def destroy
      AccessToken.revoke_all_for params[:id], current_resource_owner
      redirect_to oauth_authorized_applications_url, notice: I18n.t(:notice, scope: [:doorkeeper, :flash, :authorized_applications, :destroy])
    end
  end
end
