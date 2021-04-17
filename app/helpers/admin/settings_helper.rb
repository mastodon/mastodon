# frozen_string_literal: true

module Admin::SettingsHelper
  def site_upload_delete_hint(hint, var)
    upload = SiteUpload.find_by(var: var.to_s)
    return hint unless upload

    link = link_to t('admin.site_uploads.delete'), admin_site_upload_path(upload), data: { method: :delete }
    safe_join([hint, link], '<br/>'.html_safe)
  end
end
