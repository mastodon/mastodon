# frozen_string_literal: true

class REST::AnnualReportSerializer < ActiveModel::Serializer
  attributes :year, :data, :schema_version
end
