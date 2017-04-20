# frozen_string_literal: true

module Admin
  class SettingsController < BaseController
    BOOLEAN_SETTINGS = %w(open_registrations).freeze

    def index
      @settings = Setting.all_as_records
    end

    def update
      @setting = Setting.where(var: params[:id]).first_or_initialize(var: params[:id])
      @setting.update(value: value_for_update)

      respond_to do |format|
        format.html { redirect_to admin_settings_path }
        format.json { respond_with_bip(@setting) }
      end
    end

    private

    def settings_params
      params.require(:setting).permit(:value)
    end

    def value_for_update
      if updating_boolean_setting?
        settings_params[:value] == 'true'
      else
        settings_params[:value]
      end
    end

    def updating_boolean_setting?
      BOOLEAN_SETTINGS.include?(params[:id])
    end
  end
end
