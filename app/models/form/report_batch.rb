# frozen_string_literal: true

class Form::ReportBatch
  include ActiveModel::Model
  include Authorization
  include AccountableConcern
  include Payloadable

  attr_accessor :report_ids, :action, :current_account,
                :select_all_matching, :query

  def save
    case action
    when 'resolve'
      resolve!
    when 'assign_to_self'
      assign_to_self!
    end
  end

  private

  def resolve!
    reports.each do |report|
      resolve_report(report)
    end
  end

  def assign_to_self!
    reports.each do |report|
      assign_report(report, current_account)
    end
  end

  def reports
    if select_all_matching?
      query
    else
      Report.where(id: report_ids)
    end
  end

  def resolve_report(report)
    authorize(report, :update?)
    report.resolve!(current_account)
    log_action(:resolve, report)
  end

  def assign_report(report, account)
    authorize(report, :update?)
    report.update!(assigned_account_id: account.id)
    log_action(:assigned_to_self, report)
  end

  def select_all_matching?
    select_all_matching == '1'
  end
end
