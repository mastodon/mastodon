# frozen_string_literal: true

class AnnualReportsPresenter
  alias read_attribute_for_serialization send

  attr_reader :annual_reports

  def initialize(annual_reports)
    @annual_reports = annual_reports
  end

  def accounts
    @accounts ||= Account.where(id: @annual_reports.flat_map(&:account_ids)).includes(:account_stat, :moved_to_account, user: :role)
  end

  def statuses
    @statuses ||= Status.where(id: @annual_reports.flat_map(&:status_ids)).with_includes
  end

  def self.model_name
    @model_name ||= ActiveModel::Name.new(self)
  end
end
