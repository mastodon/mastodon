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

class Api::Activitypub::ActivitiesController < ApiController
  # before_action :set_follow, only: [:show_follow]
  before_action :set_status, only: [:show_status]

  respond_to :activitystreams2

  # Show a status in AS2 format, as either an Announce (reblog) or a Create (post) activity.
  def show_status
    return forbidden unless @status.permitted?

    if @status.reblog?
      render :show_status_announce
    else
      render :show_status_create
    end
  end

  private

  def set_status
    @status = Status.find(params[:id])
  end
end
