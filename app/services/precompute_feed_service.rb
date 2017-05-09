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
  # Fill up a user's home/mentions feed from DB and return a subset
  # @param [Symbol] type :home or :mentions
  # @param [Account] account
  def call(_, account)
    redis.pipelined do
      Status.as_home_timeline(account).limit(FeedManager::MAX_ITEMS / 4).each do |status|
        next if status.direct_visibility? || FeedManager.instance.filter?(:home, status, account.id)
        redis.zadd(FeedManager.instance.key(:home, account.id), status.id, status.reblog? ? status.reblog_of_id : status.id)
      end
    end
  end

  private

  def redis
    Redis.current
  end
end
