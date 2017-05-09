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

class AfterBlockService < BaseService
  def call(account, target_account)
    FeedManager.instance.clear_from_timeline(account, target_account)
    clear_notifications(account, target_account)
  end

  private

  def clear_notifications(account, target_account)
    Notification.where(account: account).joins(:follow).where(activity_type: 'Follow', follows: { account_id: target_account.id }).delete_all
    Notification.where(account: account).joins(mention: :status).where(activity_type: 'Mention', statuses: { account_id: target_account.id }).delete_all
    Notification.where(account: account).joins(:favourite).where(activity_type: 'Favourite', favourites: { account_id: target_account.id }).delete_all
    Notification.where(account: account).joins(:status).where(activity_type: 'Status', statuses: { account_id: target_account.id }).delete_all
  end
end
