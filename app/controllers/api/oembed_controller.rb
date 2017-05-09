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

class Api::OEmbedController < ApiController
  respond_to :json

  def show
    @stream_entry = stream_entry_from_url(params[:url])
    @width        = params[:maxwidth].present?  ? params[:maxwidth].to_i  : 400
    @height       = params[:maxheight].present? ? params[:maxheight].to_i : nil
  end

  private

  def stream_entry_from_url(url)
    params = Rails.application.routes.recognize_path(url)

    raise ActiveRecord::RecordNotFound unless recognized_stream_entry_url?(params)

    stream_entry(params)
  end

  def recognized_stream_entry_url?(params)
    %w(stream_entries statuses).include?(params[:controller]) && params[:action] == 'show'
  end

  def stream_entry(params)
    if params[:controller] == 'stream_entries'
      StreamEntry.find(params[:id])
    else
      Status.find(params[:id]).stream_entry
    end
  end
end
