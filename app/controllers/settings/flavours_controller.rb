# frozen_string_literal: true

class Settings::FlavoursController < Settings::BaseController
  layout 'admin'

  before_action :authenticate_user!

  skip_before_action :require_functional!

  def index
    redirect_to action: 'show', flavour: current_flavour
  end

  def show
    unless Themes.instance.flavours.include?(params[:flavour]) || (params[:flavour] == current_flavour)
      redirect_to action: 'show', flavour: current_flavour
    end

    @listing = Themes.instance.flavours
    @selected = params[:flavour]
  end

  def update
    user_settings.update(user_settings_params)
    redirect_to action: 'show', flavour: params[:flavour]
  end

  private

  def user_settings
    UserSettingsDecorator.new(current_user)
  end

  def user_settings_params
    { setting_flavour: params.require(:flavour),
      setting_skin: params.dig(:user, :setting_skin) }.with_indifferent_access
  end
end
