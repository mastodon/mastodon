# frozen_string_literal: true

module InvitesHelper
  def invites_max_uses_options
    [1, 5, 10, 25, 50, 100]
  end

  def invites_expires_options
    [30.minutes, 1.hour, 6.hours, 12.hours, 1.day, 1.week]
  end
end
