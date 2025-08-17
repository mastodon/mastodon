# frozen_string_literal: true

Rails.application.config.to_prepare do
  custom_css = begin
    Setting.custom_css
  rescue # Running without a cache, database, not migrated, no connection, etc
    nil
  end

  if custom_css.present?
    Rails
      .cache
      .write(
        :setting_digest_custom_css,
        Digest::SHA256.hexdigest(custom_css)
      )
  end
end
