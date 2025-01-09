# frozen_string_literal: true

module Admin::AnnouncementsHelper
  def datetime_pattern
    '[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}(:[0-9]{2}){1,2}'
  end

  def datetime_placeholder
    Time.zone.now.strftime('%FT%R')
  end
end
