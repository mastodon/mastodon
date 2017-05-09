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

class AfterRemoteFollowWorker
  include Sidekiq::Worker

  sidekiq_options queue: 'pull', retry: 5

  def perform(follow_id)
    follow          = Follow.find(follow_id)
    updated_account = FetchRemoteAccountService.new.call(follow.target_account.remote_url)

    return if updated_account.nil? || !updated_account.locked?

    follow.destroy
    FollowService.new.call(follow.account, updated_account.acct)
  rescue ActiveRecord::RecordNotFound
    true
  end
end
