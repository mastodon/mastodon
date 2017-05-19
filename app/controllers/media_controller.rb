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

class MediaController < ApplicationController
  before_action :verify_permitted_status

  def show
    redirect_to media_attachment.file.url(:original)
  end

  private

  def media_attachment
    MediaAttachment.attached.find_by!(shortcode: params[:id])
  end

  def verify_permitted_status
    raise ActiveRecord::RecordNotFound unless media_attachment.status.permitted?(current_account)
  end
end
