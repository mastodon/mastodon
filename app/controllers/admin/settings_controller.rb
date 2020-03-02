# frozen_string_literal: true

module Admin
  class SettingsController < BaseController
    include ActionView::Helpers::UrlHelper

    helper_method :site_upload_delete_link

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

    def site_upload_delete_link(var)
      upload = SiteUpload.find_by(var: var.to_s)
      return unless upload

      link = link_to t('admin.site_uploads.delete'), admin_site_upload_path(upload), data: { method: :delete }
      content_tag(:p, link, class: 'hint')
    end
  end
end
