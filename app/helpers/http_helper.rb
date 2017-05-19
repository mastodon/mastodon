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

module HttpHelper
  def http_client(options = {})
    timeout = { write: 10, connect: 10, read: 10 }.merge(options)

    HTTP.headers(user_agent: user_agent)
        .timeout(:per_operation, timeout)
        .follow
  end

  private

  def user_agent
    @user_agent ||= "#{HTTP::Request::USER_AGENT} (Mastodon/#{Mastodon::Version}; +http://#{Rails.configuration.x.local_domain}/)"
  end
end
