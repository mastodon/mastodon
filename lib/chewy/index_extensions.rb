# frozen_string_literal: true

module Chewy
  module IndexExtensions
    def index_preset(base_options = {})
      case ENV['ES_PRESET'].presence
      when 'single_node_cluster', nil
        base_options.merge(number_of_replicas: 0)
      when 'small_cluster'
        base_options.merge(number_of_replicas: 1)
      when 'large_cluster'
        base_options.merge(number_of_replicas: 1, number_of_shards: (base_options[:number_of_shards] || 1) * 2)
      end
    end
  end
end

Chewy::Index.extend(Chewy::IndexExtensions)
