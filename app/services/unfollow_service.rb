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

class UnfollowService < BaseService
  # Unfollow and notify the remote user
  # @param [Account] source_account Where to unfollow from
  # @param [Account] target_account Which to unfollow
  def call(source_account, target_account)
    follow = source_account.unfollow!(target_account)
    return unless follow
    NotificationWorker.perform_async(build_xml(follow), source_account.id, target_account.id) unless target_account.local?
    UnmergeWorker.perform_async(target_account.id, source_account.id)
  end

  private

  def build_xml(follow)
    AtomSerializer.render(AtomSerializer.new.unfollow_salmon(follow))
  end
end
