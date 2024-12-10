# frozen_string_literal: true

Rails.application.config.to_prepare do
  digest = begin
    Digest::SHA256.hexdigest(Setting.custom_css.to_s)
  rescue ActiveRecord::AdapterError # Running without a database, not migrated, no connection, etc
    :styles
  end

  Rails.cache.write(:custom_style_digest, digest)
end
