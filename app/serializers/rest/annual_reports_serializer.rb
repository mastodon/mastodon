# frozen_string_literal: true

class REST::AnnualReportsSerializer < ActiveModel::Serializer
  has_many :annual_reports, serializer: REST::AnnualReportSerializer
  has_many :accounts, serializer: REST::AccountSerializer
  has_many :statuses, serializer: REST::StatusSerializer
end
