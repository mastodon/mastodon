module Doorkeeper
  class ApplicationsController < Doorkeeper::ApplicationController
    layout 'doorkeeper/admin'

    before_action :authenticate_admin!
    before_action :set_application, only: [:show, :edit, :update, :destroy]

    def index
      @applications = if Application.respond_to?(:ordered_by)
                        Application.ordered_by(:created_at)
                      else
                        ActiveSupport::Deprecation.warn <<-MSG.squish
                          Doorkeeper #{Doorkeeper.configuration.orm} extension must implement #ordered_by
                          method for it's models as it will be used by default in Doorkeeper 5.
                        MSG

                        Application.all
                      end
    end

    def show; end

    def new
      @application = Application.new
    end

    def create
      @application = Application.new(application_params)
      if @application.save
        flash[:notice] = I18n.t(:notice, scope: [:doorkeeper, :flash, :applications, :create])
        redirect_to oauth_application_url(@application)
      else
        render :new
      end
    end

    def edit; end

    def update
      if @application.update_attributes(application_params)
        flash[:notice] = I18n.t(:notice, scope: [:doorkeeper, :flash, :applications, :update])
        redirect_to oauth_application_url(@application)
      else
        render :edit
      end
    end

    def destroy
      flash[:notice] = I18n.t(:notice, scope: [:doorkeeper, :flash, :applications, :destroy]) if @application.destroy
      redirect_to oauth_applications_url
    end

    private

    def set_application
      @application = Application.find(params[:id])
    end

    def application_params
      params.require(:doorkeeper_application).permit(:name, :redirect_uri, :scopes)
    end
  end
end
