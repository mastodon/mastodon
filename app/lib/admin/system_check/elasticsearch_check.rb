# frozen_string_literal: true

class Admin::SystemCheck::ElasticsearchCheck < Admin::SystemCheck::BaseCheck
  INDEXES = [
    InstancesIndex,
    AccountsIndex,
    TagsIndex,
    StatusesIndex,
    PublicStatusesIndex,
  ].freeze

  def skip?
    !current_user.can?(:view_devops)
  end

  def pass?
    return true unless Chewy.enabled?

    running_version.present? && compatible_version? && cluster_health['status'] == 'green' && indexes_match? && preset_matches?
  rescue Faraday::ConnectionFailed, Elasticsearch::Transport::Transport::Error
    false
  end

  def message
    if running_version.blank?
      Admin::SystemCheck::Message.new(:elasticsearch_running_check)
    elsif !compatible_version?
      Admin::SystemCheck::Message.new(
        :elasticsearch_version_check,
        I18n.t(
          'admin.system_checks.elasticsearch_version_check.version_comparison',
          running_version: running_version,
          required_version: required_version
        )
      )
    elsif !indexes_match?
      Admin::SystemCheck::Message.new(
        :elasticsearch_index_mismatch,
        mismatched_indexes.join(' ')
      )
    elsif cluster_health['status'] == 'red'
      Admin::SystemCheck::Message.new(:elasticsearch_health_red)
    elsif cluster_health['number_of_nodes'] < 2 && es_preset != 'single_node_cluster'
      Admin::SystemCheck::Message.new(:elasticsearch_preset_single_node, nil, 'https://docs.joinmastodon.org/admin/elasticsearch/#scaling')
    elsif Chewy.client.indices.get_settings[Chewy::Stash::Specification.index_name]&.dig('settings', 'index', 'number_of_replicas')&.to_i&.positive? && es_preset == 'single_node_cluster'
      Admin::SystemCheck::Message.new(:elasticsearch_reset_chewy)
    elsif cluster_health['status'] == 'yellow'
      Admin::SystemCheck::Message.new(:elasticsearch_health_yellow)
    else
      Admin::SystemCheck::Message.new(:elasticsearch_preset, nil, 'https://docs.joinmastodon.org/admin/elasticsearch/#scaling')
    end
  rescue Faraday::ConnectionFailed, Elasticsearch::Transport::Transport::Error
    Admin::SystemCheck::Message.new(:elasticsearch_running_check)
  end

  private

  def cluster_health
    @cluster_health ||= Chewy.client.cluster.health
  end

  def running_version
    @running_version ||= begin
      Chewy.client.info['version']['number']
    rescue Faraday::ConnectionFailed, Elasticsearch::Transport::Transport::Error
      nil
    end
  end

  def compatible_wire_version
    Chewy.client.info['version']['minimum_wire_compatibility_version']
  end

  def required_version
    '7.x'
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

  def indexes_match?
    mismatched_indexes.empty?
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
end
