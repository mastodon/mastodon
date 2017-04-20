# frozen_string_literal: true

module Admin
  class SettingsController < BaseController
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
      if updating_open_registrations?
        settings_params[:value] == 'true'
      else
        settings_params[:value]
      end
    end

    def updating_open_registrations?
      params[:id] == 'open_registrations'
    end
  end
end
