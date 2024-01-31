# frozen_string_literal: true

class REST::AnnualReportSerializer < REST::BaseSerializer
  attributes :year, :data, :schema_version
end
