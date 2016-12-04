# frozen_string_literal: true

module ApplicationHelper
  def active_nav_class(path)
    current_page?(path) ? 'active' : ''
  end

  def s3_expiry
    Time.zone.now.beginning_of_day.since 25.hours
  end
end
