# frozen_string_literal: true

module Admin::SettingsHelper
  def site_upload_delete_hint(hint_name, var)
    upload = SiteUpload.find_by(var: var.to_s)
    return I18n.t(hint_name) unless upload

    link = link_to t('admin.site_uploads.delete'), admin_site_upload_path(upload), data: { method: :delete }
    safe_join([I18n.t(hint_name), content_tag(:p, link, class: 'hint')])
  end
end
