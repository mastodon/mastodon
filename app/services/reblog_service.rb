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

class ReblogService < BaseService
  include StreamEntryRenderer

  # Reblog a status and notify its remote author
  # @param [Account] account Account to reblog from
  # @param [Status] reblogged_status Status to be reblogged
  # @return [Status]
  def call(account, reblogged_status)
    reblogged_status = reblogged_status.reblog if reblogged_status.reblog?

    raise Mastodon::NotPermittedError if reblogged_status.direct_visibility? || reblogged_status.private_visibility? || !reblogged_status.permitted?(account)

    reblog = account.statuses.create!(reblog: reblogged_status, text: '')

    DistributionWorker.perform_async(reblog.id)
    Pubsubhubbub::DistributionWorker.perform_async(reblog.stream_entry.id)

    if reblogged_status.local?
      NotifyService.new.call(reblog.reblog.account, reblog)
    else
      NotificationWorker.perform_async(stream_entry_to_xml(reblog.stream_entry), account.id, reblog.reblog.account_id)
    end

    reblog
  end
end
