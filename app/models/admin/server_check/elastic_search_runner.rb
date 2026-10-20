# frozen_string_literal: true

class Admin::ServerCheck::ElasticSearchRunner
  include Admin::ServerCheck::Runner

  INDEXES = [
    InstancesIndex,
    AccountsIndex,
    TagsIndex,
    StatusesIndex,
    PublicStatusesIndex,
  ].freeze

  REQUIRED_VERSION = '7.x'

  def authorized?(user)
    user.can?(:view_devops)
  end

  def run
    return ok unless Chewy.enabled?

    severity = :warning

    if running_version.blank?
      return pending(data: { reason: :running_check, running_version: :missing }, severity:)
    elsif !compatible_version?
      return pending(data: { reason: :version_check, running_version:, required_version: }, severity:)
    elsif cluster_health['status'] == 'red'
      return pending(data: { reason: :cluster_health_red }, severity:)
    elsif !indexes_match?
      return pending(
        data: {
          reason: :index_mismatch,
          mismatched_indexes:,
          mismatched_indexes_str: mismatched_indexes.join(' '),
        },
        severity:
      )
    elsif !specifications_match?
      return pending(
        data: {
          reason: :analysis_index_mismatch,
          mismatched_specifications_indexes:,
          mismatched_specifications_indexes_str: mismatched_specifications_indexes.join(' '),
        },
        severity:
      )
    elsif low_number_of_nodes?
      return pending(data: { reason: :preset_single_node }, severity:)
    elsif reset_chewy?
      return pending(data: { reason: :reset_chewy }, severity:)
    elsif cluster_health['status'] == 'yellow'
      return pending(data: { reason: :cluster_health_yellow }, severity:)
    elsif !preset_matches?
      return pending(data: { reason: :preset }, severity:)
    end

    ok
  rescue Faraday::ConnectionFailed, Elastic::Transport::Transport::Error, HTTPClient::KeepAliveDisconnected => e
    error(data: { error: e.message })
  end

  private

  def cluster_health
    @cluster_health ||= Chewy.client.cluster.health
  end

  def running_version
    @running_version ||= begin
      Chewy.client.info.dig('version', 'number')
    rescue Faraday::ConnectionFailed, Elastic::Transport::Transport::Error
      nil
    end
  end

  def compatible_wire_version
    Chewy.client.info['version']['minimum_wire_compatibility_version']
  end

  def required_version
    REQUIRED_VERSION
  end

  def compatible_version?
    running_version_ok? || compatible_wire_version_ok?
  rescue ArgumentError
    false
  end

  def running_version_ok?
    return false if running_version.blank?

    gem_version_running >= gem_version_required
  end

  def compatible_wire_version_ok?
    return false if compatible_wire_version.blank?

    gem_version_compatible_wire >= gem_version_required
  end

  def gem_version_running
    Gem::Version.new(running_version)
  end

  def gem_version_required
    Gem::Version.new(required_version)
  end

  def gem_version_compatible_wire
    Gem::Version.new(compatible_wire_version)
  end

  def mismatched_indexes
    @mismatched_indexes ||= INDEXES.filter_map do |klass|
      klass.base_name if Chewy.client.indices.get_mapping[klass.index_name]&.deep_symbolize_keys != klass.mappings_hash
    end
  end

  def mismatched_specifications_indexes
    @mismatched_specifications_indexes ||= INDEXES.filter_map do |klass|
      klass.base_name if klass.specification.changed?
    end
  end

  def indexes_match?
    mismatched_indexes.empty?
  end

  def specifications_match?
    mismatched_specifications_indexes.empty?
  end

  def es_preset
    ENV.fetch('ES_PRESET', 'single_node_cluster')
  end

  def preset_matches?
    case es_preset
    when 'single_node_cluster'
      cluster_health['number_of_nodes'] == 1
    else
      cluster_health['number_of_nodes'] > 1
    end
  end

  def low_number_of_nodes?
    cluster_health['number_of_nodes'] < 2 && es_preset != 'single_node_cluster'
  end

  def reset_chewy?
    Chewy.client.indices
      .get_settings[Chewy::Stash::Specification.index_name]
      &.dig('settings', 'index', 'number_of_replicas')&.to_i&.positive? && es_preset == 'single_node_cluster'
  end
end
