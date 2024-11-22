# frozen_string_literal: true

class Settings::ApplicationsController < Settings::BaseController
  before_action :set_application, only: [:show, :update, :destroy, :regenerate]
  before_action :prepare_scopes, only: [:create, :update]

  def index
    @applications = current_user.applications.order(id: :desc).page(params[:page])
  end

  def show; end

  def new
    @application = Doorkeeper::Application.new(
      redirect_uri: Doorkeeper.configuration.native_redirect_uri,
      scopes: 'profile'
    )
  end

  def create
    @application = current_user.applications.build(application_params)

    if @application.save
      redirect_to settings_applications_path, notice: I18n.t('applications.created')
    else
      render :new
    end
  end

  def update
    if @application.update(application_params)
      if @application.scopes_previously_changed?
        @access_token = current_user.token_for_app(@application)
        @access_token.destroy
        redirect_to settings_application_path(@application), notice: I18n.t('applications.token_regenerated')
      else
        redirect_to settings_application_path(@application), notice: I18n.t('generic.changes_saved_msg')
      end
    else
      render :show
    end
  end

  def destroy
    @application.destroy
    redirect_to settings_applications_path, notice: I18n.t('applications.destroyed')
  end

  def regenerate
    @access_token = current_user.token_for_app(@application)
    @access_token.destroy

    redirect_to settings_application_path(@application), notice: I18n.t('applications.token_regenerated')
  end

  private

  def set_application
    @application = current_user.applications.find(params[:id])
  end

  def application_params
    params.require(:doorkeeper_application).permit(
      :name,
      :redirect_uri,
      :scopes,
      :website
    )
  end

  def prepare_scopes
    scopes = params.fetch(:doorkeeper_application, {}).fetch(:scopes, nil)
    params[:doorkeeper_application][:scopes] = scopes.join(' ') if scopes.is_a? Array
  end
end
