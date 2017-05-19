# frozen_string_literal: true
#
# Mastodon, a GNU Social-compatible microblogging server
# Copyright (C) 2016-2017 Eugen Rochko & al (see the AUTHORS file)
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#

module UserTrackingConcern
  extend ActiveSupport::Concern

  REGENERATE_FEED_DAYS = 14
  UPDATE_SIGN_IN_HOURS = 24

  included do
    before_action :set_user_activity, if: %i(user_signed_in? user_needs_sign_in_update?)
  end

  private

  def set_user_activity
    # Mark as signed-in today
    current_user.update_tracked_fields!(request)

    # Regenerate feed if needed
    RegenerationWorker.perform_async(current_user.account_id) if user_needs_feed_update?
  end

  def user_needs_sign_in_update?
    current_user.current_sign_in_at.nil? || current_user.current_sign_in_at < UPDATE_SIGN_IN_HOURS.hours.ago
  end

  def user_needs_feed_update?
    current_user.last_sign_in_at < REGENERATE_FEED_DAYS.days.ago
  end
end
