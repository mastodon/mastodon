# frozen_string_literal: true

class Admin::Metrics::Dimension
  DIMENSIONS = {
    languages: Admin::Metrics::Dimension::LanguagesDimension,
    sources: Admin::Metrics::Dimension::SourcesDimension,
    servers: Admin::Metrics::Dimension::ServersDimension,
    space_usage: Admin::Metrics::Dimension::SpaceUsageDimension,
    software_versions: Admin::Metrics::Dimension::SoftwareVersionsDimension,
    tag_servers: Admin::Metrics::Dimension::TagServersDimension,
    tag_languages: Admin::Metrics::Dimension::TagLanguagesDimension,
  }.freeze

  def self.retrieve(dimension_keys, start_at, end_at, limit, params)
    Array(dimension_keys).map do |key|
      klass = DIMENSIONS[key.to_sym]
      klass&.new(start_at, end_at, limit, klass.with_params? ? params.require(key.to_sym) : nil)
    end.compact
  end
end
