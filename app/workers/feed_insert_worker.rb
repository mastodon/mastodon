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

class FeedInsertWorker
  include Sidekiq::Worker

  attr_reader :status, :follower

  def perform(status_id, follower_id)
    @status = Status.find_by(id: status_id)
    @follower = Account.find_by(id: follower_id)

    check_and_insert
  end

  private

  def check_and_insert
    if records_available?
      perform_push unless feed_filtered?
    else
      true
    end
  end

  def records_available?
    status.present? && follower.present?
  end

  def feed_filtered?
    FeedManager.instance.filter?(:home, status, follower.id)
  end

  def perform_push
    FeedManager.instance.push(:home, follower, status)
  end
end
