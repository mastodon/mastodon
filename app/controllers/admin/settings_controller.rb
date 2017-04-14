# frozen_string_literal: true

module Admin
  class SettingsController < BaseController
    def index
      @settings = Setting.all_as_records
    end

    def update
      @setting = Setting.where(var: params[:id]).first_or_initialize(var: params[:id])
      value    = settings_params[:value]

      # Special cases
      value = value == 'true' if @setting.var == 'open_registrations'

      if @setting.value != value
        @setting.value = value
        @setting.save
      end

      respond_to do |format|
        format.html { redirect_to admin_settings_path }
        format.json { respond_with_bip(@setting) }
      end
    end

    private

    def settings_params
      params.require(:setting).permit(:value)
    end
  end
end
