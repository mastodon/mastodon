# frozen_string_literal: true

module Admin
  class SettingsController < BaseController
    ADMIN_SETTINGS = {
      site_title: :string,
      site_description: :text,
      site_extended_description: :text,
      site_contact_email: :string,
      site_contact_username: :string,
      open_registrations: :boolean,
      closed_registrations_message: :text,
    }.freeze
    BOOLEAN_SETTINGS = %w(open_registrations).freeze

    before_action :set_setting, only: [:edit, :update]

    def index
      @settings = ADMIN_SETTINGS.keys
    end

    def edit
    end

    def update
      if @setting.update(value: value_for_update)
        flash[:notice] = 'Success'
        redirect_to admin_settings_path
      else
        render :edit
      end
    end

    private

    def typecast_setting(setting)
      ADMIN_SETTINGS[setting.to_sym]
    end
    helper_method :typecast_setting

    def set_setting
      @setting = Setting.where(var: params[:id]).first_or_initialize(var: params[:id])
    end

    def settings_params
      params.require(:setting).permit(:value)
    end

    def value_for_update
      if updating_boolean_setting?
        settings_params[:value] == '1'
      else
        settings_params[:value]
      end
    end

    def updating_boolean_setting?
      BOOLEAN_SETTINGS.include?(params[:id])
    end
  end
end
