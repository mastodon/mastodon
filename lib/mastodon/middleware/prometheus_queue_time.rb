# frozen_string_literal: true

module Mastodon
  module Middleware
    class PrometheusQueueTime < ::PrometheusExporter::Middleware
      # Overwrite to only collect the queue time metric
      def call(env)
        queue_time = measure_queue_time(env)

        result = @app.call(env)

        result
      ensure
        obj = {
          type: 'web',
          queue_time: queue_time,
          default_labels: default_labels(env, result),
        }
        labels = custom_labels(env)
        obj = obj.merge(custom_labels: labels) if labels

        @client.send_json(obj)
      end
    end
  end
end
