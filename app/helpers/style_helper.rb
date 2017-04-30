# frozen_string_literal: true

module StyleHelper
  def stylesheet_for_layout
    theme_asset = current_user&.setting_theme && "themes/#{current_user&.setting_theme}/application.css"
    if theme_asset && asset_exist?(theme_asset)
      theme_asset
    elsif asset_exist? 'custom.css'
      'custom'
    else
      'application'
    end
  end

  def asset_exist?(path)
    if Rails.configuration.assets.compile
      Rails.application.precompiled_assets.include? path
    else
      Rails.application.assets_manifest.assets[path].present?
    end
  end
end
