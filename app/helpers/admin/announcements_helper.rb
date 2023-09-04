# frozen_string_literal: true

module Admin::AnnouncementsHelper
  def time_range(announcement)
    if announcement.all_day?
      safe_join([l(announcement.starts_at.to_date), ' - ', l(announcement.ends_at.to_date)])
    else
      safe_join([l(announcement.starts_at), ' - ', l(announcement.ends_at)])
    end
  end
end
