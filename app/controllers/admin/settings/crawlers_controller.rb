# frozen_string_literal: true

class Admin::Settings::CrawlersController < Admin::SettingsController
  private

  def after_update_redirect_path
    admin_settings_crawlers_path
  end
end
