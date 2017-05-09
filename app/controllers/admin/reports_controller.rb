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

module Admin
  class ReportsController < BaseController
    before_action :set_report, except: [:index]

    def index
      @reports = filtered_reports.page(params[:page])
    end

    def show; end

    def update
      process_report
      redirect_to admin_report_path(@report)
    end

    private

    def process_report
      case params[:outcome].to_s
      when 'resolve'
        @report.update(action_taken_by_current_attributes)
      when 'suspend'
        Admin::SuspensionWorker.perform_async(@report.target_account.id)
        resolve_all_target_account_reports
      when 'silence'
        @report.target_account.update(silenced: true)
        resolve_all_target_account_reports
      else
        raise ActiveRecord::RecordNotFound
      end
    end

    def action_taken_by_current_attributes
      { action_taken: true, action_taken_by_account_id: current_account.id }
    end

    def resolve_all_target_account_reports
      unresolved_reports_for_target_account.update_all(
        action_taken_by_current_attributes
      )
    end

    def unresolved_reports_for_target_account
      Report.where(
        target_account: @report.target_account
      ).unresolved
    end

    def filtered_reports
      ReportFilter.new(filter_params).results.order('id desc').includes(
        :account,
        :target_account
      )
    end

    def filter_params
      params.permit(
        :account_id,
        :resolved,
        :target_account_id
      )
    end

    def set_report
      @report = Report.find(params[:id])
    end
  end
end
