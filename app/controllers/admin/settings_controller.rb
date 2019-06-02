# frozen_string_literal: true

module Admin
  class SettingsController < BaseController
    ADMIN_SETTINGS = %w(
      site_contact_username
      site_contact_email
      site_title
      site_short_description
      site_description
      site_extended_description
      site_terms
      open_registrations
      max_toot_chars
      closed_registrations_message
      open_deletion
      timeline_preview
      show_staff_badge
      bootstrap_timeline_accounts
      theme
      thumbnail
      hero
      mascot
      min_invite_role
      activity_api_enabled
      peers_api_enabled
      show_known_fediverse_at_about_page
      preview_sensitive_media
      custom_css
      profile_directory
    ).freeze

    BOOLEAN_SETTINGS = %w(
      open_registrations
      open_deletion
      timeline_preview
      show_staff_badge
      activity_api_enabled
      peers_api_enabled
      show_known_fediverse_at_about_page
      preview_sensitive_media
      profile_directory
    ).freeze

    UPLOAD_SETTINGS = %w(
      thumbnail
      hero
      mascot
    ).freeze

    def edit
      authorize :settings, :show?

      @admin_settings = Form::AdminSettings.new
    end

    def update
      authorize :settings, :update?

      @admin_settings = Form::AdminSettings.new(settings_params)

      if @admin_settings.save
        flash[:notice] = I18n.t('generic.changes_saved_msg')
        redirect_to edit_admin_settings_path
      else
        render :edit
      end
    end

    private

    def settings_params
      params.require(:form_admin_settings).permit(*Form::AdminSettings::KEYS)
    end
  end
end
