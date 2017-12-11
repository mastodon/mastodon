# frozen_string_literal: true

class Settings::FlavoursController < Settings::BaseController

  def index
    redirect_to action: 'show', flavour: current_flavour
  end

  def show
    unless Themes.instance.flavours.include?(params[:flavour]) or params[:flavour] == current_flavour
      redirect_to action: 'show', flavour: current_flavour
    end

    @listing = Themes.instance.flavours
    @selected = params[:flavour]
  end

  def update
    user_settings.update(user_settings_params(params[:flavour]).to_h)
    redirect_to action: 'show', flavour: params[:flavour]
  end

  private

  def user_settings
    UserSettingsDecorator.new(current_user)
  end

  def user_settings_params(flavour)
    params.require(:user).merge({ setting_flavour: flavour }).permit(
      :setting_flavour,
      :setting_skin
    )
  end
end
