# frozen_string_literal: true

class Settings::ApplicationsController < ApplicationController
  layout 'admin'

  before_action :authenticate_user!

  def index
    @applications = current_user.applications.page(params[:page])
  end

  def new
    @application = Doorkeeper::Application.new(
      redirect_uri: Doorkeeper.configuration.native_redirect_uri,
      scopes: 'read write follow'
    )
  end

  def show
    @application = current_user.applications.find(params[:id])
  end

  def create
    @application = current_user.applications.build(application_params)
    if @application.save
      redirect_to settings_applications_path, notice: I18n.t('application.created')
    else
      render :new
    end
  end

  def update
    @application = current_user.applications.find(params[:id])
    if @application.update_attributes(application_params)
      redirect_to settings_applications_path, notice: I18n.t('generic.changes_saved_msg')
    else
      render :show
    end
  end

  def destroy
    @application = current_user.applications.find(params[:id])
    @application.destroy
    redirect_to settings_applications_path, notice: t('application.destroyed')
  end

  def regenerate
    @application = current_user.applications.find(params[:application_id])
    @access_token = current_user.token_for_app(@application)
    @access_token.destroy

    redirect_to settings_application_path(@application), notice: t('access_token.regenerated')
  end

  private

  def application_params
    params.require(:doorkeeper_application).permit(
      :name,
      :redirect_uri,
      :scopes,
      :website
    )
  end
end
