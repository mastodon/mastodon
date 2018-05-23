module Lograge
  module Formatters
    class Logstash
      def call(data)
        load_dependencies
        event = LogStash::Event.new(data)

        event['message'] = "[#{data[:status]}] #{data[:method]} #{data[:path]} (#{data[:controller]}##{data[:action]})"
        event.to_json
      end

      def load_dependencies
        require 'logstash-event'
      rescue LoadError
        puts 'You need to install the logstash-event gem to use the logstash output.'
        raise
      end
    end
  end
end
