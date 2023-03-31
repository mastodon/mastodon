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
    current_user.settings.update(flavour: params.require(:flavour), skin: params.dig(:user, :setting_skin))
    current_user.save
    redirect_to action: 'show', flavour: params[:flavour]
  end
end
