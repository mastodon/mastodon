# frozen_string_literal: true

class Admin::Metrics::Dimension
  DIMENSIONS = {
    languages: LanguagesDimension,
    sources: SourcesDimension,
    servers: ServersDimension,
    space_usage: SpaceUsageDimension,
    software_versions: SoftwareVersionsDimension,
    tag_servers: TagServersDimension,
    tag_languages: TagLanguagesDimension,
    instance_accounts: InstanceAccountsDimension,
    instance_languages: InstanceLanguagesDimension,
  }.freeze

  def self.retrieve(dimension_keys, start_at, end_at, limit, params)
    Array(dimension_keys).filter_map do |key|
      klass = DIMENSIONS[key.to_sym]
      klass&.new(start_at, end_at, limit, klass.with_params? ? params.require(key.to_sym) : nil)
    end
  end
end
