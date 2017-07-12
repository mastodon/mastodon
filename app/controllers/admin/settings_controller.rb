# frozen_string_literal: true

module Admin
  class SettingsController < BaseController
    ADMIN_SETTINGS = %w(
      site_contact_username
      site_contact_email
      site_title
      site_description
      site_extended_description
      site_terms
      open_registrations
      closed_registrations_message
      open_deletion
      timeline_preview
    ).freeze

    BOOLEAN_SETTINGS = %w(
      open_registrations
      open_deletion
      timeline_preview
    ).freeze

    def edit
      @admin_settings = Form::AdminSettings.new
    end

    def update
      settings_params.each do |key, value|
        setting = Setting.where(var: key).first_or_initialize(var: key)
        setting.update(value: value_for_update(key, value))
      end

      flash[:notice] = I18n.t('generic.changes_saved_msg')
      redirect_to edit_admin_settings_path
    end

    private

    def settings_params
      params.require(:form_admin_settings).permit(ADMIN_SETTINGS)
    end

    def value_for_update(key, value)
      if BOOLEAN_SETTINGS.include?(key)
        value == '1'
      else
        value
      end
    end
  end
end
