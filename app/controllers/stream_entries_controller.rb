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

class StreamEntriesController < ApplicationController
  layout 'public'

  before_action :set_account
  before_action :set_stream_entry
  before_action :set_link_headers
  before_action :check_account_suspension

  def show
    respond_to do |format|
      format.html do
        return gone if @stream_entry.activity.nil?

        if @stream_entry.activity_type == 'Status'
          @ancestors   = @stream_entry.activity.reply? ? cache_collection(@stream_entry.activity.ancestors(current_account), Status) : []
          @descendants = cache_collection(@stream_entry.activity.descendants(current_account), Status)
        end
      end

      format.atom do
        render xml: AtomSerializer.render(AtomSerializer.new.entry(@stream_entry, true))
      end
    end
  end

  def embed
    response.headers['X-Frame-Options'] = 'ALLOWALL'
    return gone if @stream_entry.activity.nil?

    render layout: 'embedded'
  end

  private

  def set_account
    @account = Account.find_local!(params[:account_username])
  end

  def set_link_headers
    response.headers['Link'] = LinkHeader.new([[account_stream_entry_url(@account, @stream_entry, format: 'atom'), [%w(rel alternate), %w(type application/atom+xml)]]])
  end

  def set_stream_entry
    @stream_entry = @account.stream_entries.where(activity_type: 'Status').find(params[:id])
    @type         = @stream_entry.activity_type.downcase

    raise ActiveRecord::RecordNotFound if @stream_entry.activity.nil? || (@stream_entry.hidden? && (@stream_entry.activity_type != 'Status' || (@stream_entry.activity_type == 'Status' && !@stream_entry.activity.permitted?(current_account))))
  end

  def check_account_suspension
    gone if @account.suspended?
  end
end
