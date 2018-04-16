require 'fog/openstack/models/collection'
require 'fog/metric/openstack/models/metric'

module Fog
  module Metric
    class OpenStack
      class Metrics < Fog::OpenStack::Collection

        model Fog::Metric::OpenStack::Metric

        def all(options = {})
          load_response(service.list_metrics(options))
        end

        def find_by_id(metric_id)
          resource = service.get_metric(metric_id).body
          new(resource)
        rescue Fog::Metric::OpenStack::NotFound
          nil
        end

        def find_measures_by_id(metric_id, options = {})
          resource = service.get_metric_measures(metric_id, options).body
          new(resource)
        rescue Fog::Metric::OpenStack::NotFound
          nil
        end
      end
    end
  end
end
