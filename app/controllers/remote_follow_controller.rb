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

class RemoteFollowController < ApplicationController
  layout 'public'

  before_action :set_account
  before_action :gone, if: :suspended_account?

  def new
    @remote_follow = RemoteFollow.new(session_params)
  end

  def create
    @remote_follow = RemoteFollow.new(resource_params)

    if @remote_follow.valid?
      session[:remote_follow] = @remote_follow.acct
      redirect_to @remote_follow.subscribe_address_for(@account)
    else
      render :new
    end
  end

  private

  def resource_params
    params.require(:remote_follow).permit(:acct)
  end

  def session_params
    { acct: session[:remote_follow] }
  end

  def set_account
    @account = Account.find_local!(params[:account_username])
  end

  def suspended_account?
    @account.suspended?
  end
end
