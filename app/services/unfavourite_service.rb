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

class UnfavouriteService < BaseService
  def call(account, status)
    favourite = Favourite.find_by!(account: account, status: status)
    favourite.destroy!

    NotificationWorker.perform_async(build_xml(favourite), account.id, status.account_id) unless status.local?

    favourite
  end

  private

  def build_xml(favourite)
    AtomSerializer.render(AtomSerializer.new.unfavourite_salmon(favourite))
  end
end
