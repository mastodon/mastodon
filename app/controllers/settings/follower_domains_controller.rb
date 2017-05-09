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

class Settings::FollowerDomainsController < ApplicationController
  layout 'admin'

  before_action :authenticate_user!

  def show
    @account = current_account
    @domains = current_account.followers.reorder(nil).group('accounts.domain').select('accounts.domain, count(accounts.id) as accounts_from_domain').page(params[:page]).per(10)
  end

  def update
    domains = bulk_params[:select] || []

    domains.each do |domain|
      SoftBlockDomainFollowersWorker.perform_async(current_account.id, domain)
    end

    redirect_to settings_follower_domains_path, notice: I18n.t('followers.success', count: domains.size)
  end

  private

  def bulk_params
    params.permit(select: [])
  end
end
