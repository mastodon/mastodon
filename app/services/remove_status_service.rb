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

class RemoveStatusService < BaseService
  include StreamEntryRenderer

  def call(status)
    @payload = Oj.dump(event: :delete, payload: status.id)

    remove_from_self(status) if status.account.local?
    remove_from_followers(status)
    remove_from_mentioned(status)
    remove_reblogs(status)
    remove_from_hashtags(status)
    remove_from_public(status)

    status.destroy!

    return unless status.account.local?

    Pubsubhubbub::DistributionWorker.perform_async(status.stream_entry.id)
  end

  private

  def remove_from_self(status)
    unpush(:home, status.account, status)
  end

  def remove_from_followers(status)
    status.account.followers.where(domain: nil).each do |follower|
      unpush(:home, follower, status)
    end
  end

  def remove_from_mentioned(status)
    return unless status.local?
    notified_domains = []

    status.mentions.each do |mention|
      mentioned_account = mention.account

      next if mentioned_account.local?
      next if notified_domains.include?(mentioned_account.domain)

      notified_domains << mentioned_account.domain
      send_delete_salmon(mentioned_account, status)
    end
  end

  def send_delete_salmon(account, status)
    return unless status.local?
    NotificationWorker.perform_async(stream_entry_to_xml(status.stream_entry), status.account_id, account.id)
  end

  def remove_reblogs(status)
    status.reblogs.each do |reblog|
      RemoveStatusService.new.call(reblog)
    end
  end

  def unpush(type, receiver, status)
    if status.reblog? && !redis.zscore(FeedManager.instance.key(type, receiver.id), status.reblog_of_id).nil?
      redis.zadd(FeedManager.instance.key(type, receiver.id), status.reblog_of_id, status.reblog_of_id)
    else
      redis.zremrangebyscore(FeedManager.instance.key(type, receiver.id), status.id, status.id)
    end

    Redis.current.publish("timeline:#{receiver.id}", @payload)
  end

  def remove_from_hashtags(status)
    status.tags.pluck(:name) do |hashtag|
      Redis.current.publish("timeline:hashtag:#{hashtag}", @payload)
      Redis.current.publish("timeline:hashtag:#{hashtag}:local", @payload) if status.local?
    end
  end

  def remove_from_public(status)
    Redis.current.publish('timeline:public', @payload)
    Redis.current.publish('timeline:public:local', @payload) if status.local?
  end

  def redis
    Redis.current
  end
end
