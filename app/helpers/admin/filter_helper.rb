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

module Admin::FilterHelper
  ACCOUNT_FILTERS = %i(local remote by_domain silenced suspended recent username display_name email ip).freeze
  REPORT_FILTERS = %i(resolved account_id target_account_id).freeze

  FILTERS = ACCOUNT_FILTERS + REPORT_FILTERS

  def filter_link_to(text, more_params)
    new_url = filtered_url_for(more_params)
    link_to text, new_url, class: filter_link_class(new_url)
  end

  def table_link_to(icon, text, path, options = {})
    link_to safe_join([fa_icon(icon), text]), path, options.merge(class: 'table-action-link')
  end

  private

  def filter_params(more_params)
    controller_request_params.merge(more_params)
  end

  def filter_link_class(new_url)
    filtered_url_for(controller_request_params) == new_url ? 'selected' : ''
  end

  def filtered_url_for(url_params)
    url_for filter_params(url_params)
  end

  def controller_request_params
    params.permit(FILTERS)
  end
end
