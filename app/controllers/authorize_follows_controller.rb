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

class AuthorizeFollowsController < ApplicationController
  layout 'public'

  before_action :authenticate_user!

  def show
    @account = located_account || render(:error)
  end

  def create
    @account = follow_attempt.try(:target_account)

    if @account.nil?
      render :error
    else
      redirect_to web_url("accounts/#{@account.id}")
    end
  rescue ActiveRecord::RecordNotFound, Mastodon::NotPermittedError
    render :error
  end

  private

  def follow_attempt
    FollowService.new.call(current_account, acct_without_prefix)
  end

  def located_account
    if acct_param_is_url?
      account_from_remote_fetch
    else
      account_from_remote_follow
    end
  end

  def account_from_remote_fetch
    FetchRemoteAccountService.new.call(acct_without_prefix)
  end

  def account_from_remote_follow
    FollowRemoteAccountService.new.call(acct_without_prefix)
  end

  def acct_param_is_url?
    parsed_uri.path && %w(http https).include?(parsed_uri.scheme)
  end

  def parsed_uri
    Addressable::URI.parse(acct_without_prefix).normalize
  end

  def acct_without_prefix
    acct_params.gsub(/\Aacct:/, '')
  end

  def acct_params
    params.fetch(:acct, '')
  end
end
