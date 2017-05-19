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
require 'sidekiq-scheduler'

class Scheduler::SubscriptionsScheduler
  include Sidekiq::Worker

  def perform
    logger.info 'Queueing PuSH re-subscriptions'

    expiring_accounts.pluck(:id).each do |id|
      Pubsubhubbub::SubscribeWorker.perform_async(id)
    end
  end

  private

  def expiring_accounts
    Account.expiring(1.day.from_now).partitioned
  end
end
