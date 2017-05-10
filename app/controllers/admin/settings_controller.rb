# frozen_string_literal: true

module Admin
  class SettingsController < BaseController
    ADMIN_SETTINGS = %w(
      site_contact_username
      site_contact_email
      site_title
      site_description
      site_extended_description
      open_registrations
      closed_registrations_message
    ).freeze
    BOOLEAN_SETTINGS = %w(open_registrations).freeze

    def edit
      @settings = Setting.all_as_records
    end

    def update
      settings_params.each do |key, value|
        setting = Setting.where(var: key).first_or_initialize(var: key)
        setting.update(value: value_for_update(key, value))
      end

      flash[:notice] = 'Success!'
      redirect_to edit_admin_settings_path
    end

    private

    def settings_params
      params.permit(ADMIN_SETTINGS)
    end

    def value_for_update(key, value)
      if BOOLEAN_SETTINGS.include?(key)
        value == 'true'
      else
        value
      end
    end
  end
end
