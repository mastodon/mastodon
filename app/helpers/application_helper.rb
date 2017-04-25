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
end
