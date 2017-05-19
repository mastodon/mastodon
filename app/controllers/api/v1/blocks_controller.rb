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

class Api::V1::BlocksController < ApiController
  before_action -> { doorkeeper_authorize! :follow }
  before_action :require_user!

  respond_to :json

  def index
    results   = Block.where(account: current_account).paginate_by_max_id(limit_param(DEFAULT_ACCOUNTS_LIMIT), params[:max_id], params[:since_id])
    accounts  = Account.where(id: results.map(&:target_account_id)).map { |a| [a.id, a] }.to_h
    @accounts = results.map { |f| accounts[f.target_account_id] }.compact

    next_path = api_v1_blocks_url(pagination_params(max_id: results.last.id))    if results.size == limit_param(DEFAULT_ACCOUNTS_LIMIT)
    prev_path = api_v1_blocks_url(pagination_params(since_id: results.first.id)) unless results.empty?

    set_pagination_headers(next_path, prev_path)
  end

  private

  def pagination_params(core_params)
    params.permit(:limit).merge(core_params)
  end
end
