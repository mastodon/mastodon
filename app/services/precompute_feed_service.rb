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

class PrecomputeFeedService < BaseService
  LIMIT = FeedManager::MAX_ITEMS / 4

  def call(account)
    @account = account
    populate_feed
  end

  private

  attr_reader :account

  def populate_feed
    redis.pipelined do
      statuses.each do |status|
        process_status(status)
      end
    end
  end

  def process_status(status)
    add_status_to_feed(status) unless skip_status?(status)
  end

  def skip_status?(status)
    status.direct_visibility? || status_filtered?(status)
  end

  def add_status_to_feed(status)
    redis.zadd(account_home_key, status.id, status.reblog? ? status.reblog_of_id : status.id)
  end

  def status_filtered?(status)
    FeedManager.instance.filter?(:home, status, account.id)
  end

  def account_home_key
    FeedManager.instance.key(:home, account.id)
  end

  def statuses
    Status.as_home_timeline(account).order(account_id: :desc).limit(LIMIT)
  end

  def redis
    Redis.current
  end
end
