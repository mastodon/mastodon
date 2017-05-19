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

class StatusesController < ApplicationController
  layout 'public'

  before_action :set_account
  before_action :set_status
  before_action :set_link_headers
  before_action :check_account_suspension

  def show
    @ancestors   = @status.reply? ? cache_collection(@status.ancestors(current_account), Status) : []
    @descendants = cache_collection(@status.descendants(current_account), Status)

    render 'stream_entries/show'
  end

  private

  def set_account
    @account = Account.find_local!(params[:account_username])
  end

  def set_link_headers
    response.headers['Link'] = LinkHeader.new([[account_stream_entry_url(@account, @status.stream_entry, format: 'atom'), [%w(rel alternate), %w(type application/atom+xml)]]])
  end

  def set_status
    @status       = @account.statuses.find(params[:id])
    @stream_entry = @status.stream_entry
    @type         = @stream_entry.activity_type.downcase

    raise ActiveRecord::RecordNotFound unless @status.permitted?(current_account)
  end

  def check_account_suspension
    gone if @account.suspended?
  end
end
