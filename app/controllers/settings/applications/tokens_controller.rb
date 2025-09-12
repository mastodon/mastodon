# frozen_string_literal: true

module Settings
  class Applications::TokensController < BaseController
    before_action :set_application

    def destroy
      @access_token = current_user.token_for_app(@application)
      @access_token.destroy

      redirect_to settings_application_path(@application), notice: t('applications.token_regenerated')
    end

    private

    def set_application
      @application = current_user.applications.find(params[:application_id])
    end
  end
end
