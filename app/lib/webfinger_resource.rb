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

class WebfingerResource
  attr_reader :resource

  def initialize(resource)
    @resource = resource
  end

  def username
    case resource
    when /\Ahttps?/i
      username_from_url
    when /\@/
      username_from_acct
    else
      raise(ActiveRecord::RecordNotFound)
    end
  end

  private

  def username_from_url
    if account_show_page?
      path_params[:username]
    else
      raise ActiveRecord::RecordNotFound
    end
  end

  def account_show_page?
    path_params[:controller] == 'accounts' && path_params[:action] == 'show'
  end

  def path_params
    Rails.application.routes.recognize_path(resource)
  end

  def username_from_acct
    if domain_matches_local?
      local_username
    else
      raise ActiveRecord::RecordNotFound
    end
  end

  def split_acct
    resource_without_acct_string.split('@')
  end

  def resource_without_acct_string
    resource.gsub(/\Aacct:/, '')
  end

  def local_username
    split_acct.first
  end

  def local_domain
    split_acct.last
  end

  def domain_matches_local?
    TagManager.instance.local_domain?(local_domain) || TagManager.instance.web_domain?(local_domain)
  end
end
