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

class Api::V1::ReportsController < ApiController
  before_action -> { doorkeeper_authorize! :read }, except: [:create]
  before_action -> { doorkeeper_authorize! :write }, only:  [:create]
  before_action :require_user!

  respond_to :json

  def index
    @reports = Report.where(account: current_account)
  end

  def create
    status_ids = report_params[:status_ids].is_a?(Enumerable) ? report_params[:status_ids] : [report_params[:status_ids]]

    @report = Report.create!(account: current_account,
                             target_account: Account.find(report_params[:account_id]),
                             status_ids: Status.find(status_ids).pluck(:id),
                             comment: report_params[:comment])

    render :show
  end

  private

  def report_params
    params.permit(:account_id, :comment, status_ids: [])
  end
end
