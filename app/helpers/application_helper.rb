# frozen_string_literal: true

module ApplicationHelper
  def active_nav_class(path)
    current_page?(path) ? 'active' : ''
  end

  def show_landing_strip?
    !user_signed_in? && !single_user_mode?
  end

  def add_rtl_body_class(other_classes)
    other_classes = "#{other_classes} rtl" if [:ar, :fa].include?(I18n.locale)
    other_classes
  end

  def favicon_path
    env_suffix = Rails.env.production? ? '' : '-dev'
    asset_path "favicon#{env_suffix}.ico"
  end

  def title
    Rails.env.production? ? site_title : "#{site_title} (Dev)"
  end
end
