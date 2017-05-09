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

class AccountsController < ApplicationController
  include AccountControllerConcern

  def show
    respond_to do |format|
      format.html do
        @statuses = @account.statuses.permitted_for(@account, current_account).order('id desc').paginate_by_max_id(20, params[:max_id], params[:since_id])
        @statuses = cache_collection(@statuses, Status)
      end

      format.atom do
        @entries = @account.stream_entries.order('id desc').where(hidden: false).with_includes.paginate_by_max_id(20, params[:max_id], params[:since_id])
        render xml: AtomSerializer.render(AtomSerializer.new.feed(@account, @entries.to_a))
      end

      format.activitystreams2
    end
  end

  private

  def set_account
    @account = Account.find_local!(params[:username])
  end
end
