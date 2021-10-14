# frozen_string_literal: true

class Admin::Metrics::Dimension
  DIMENSIONS = {
    languages: Admin::Metrics::Dimension::LanguagesDimension,
    sources: Admin::Metrics::Dimension::SourcesDimension,
    servers: Admin::Metrics::Dimension::ServersDimension,
    space_usage: Admin::Metrics::Dimension::SpaceUsageDimension,
    software_versions: Admin::Metrics::Dimension::SoftwareVersionsDimension,
  }.freeze

  def self.retrieve(dimension_keys, start_at, end_at, limit)
    Array(dimension_keys).map { |key| DIMENSIONS[key.to_sym]&.new(start_at, end_at, limit) }.compact
  end
end
