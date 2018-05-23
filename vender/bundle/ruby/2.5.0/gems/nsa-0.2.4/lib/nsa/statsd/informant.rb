require "nsa/collectors/action_controller"
require "nsa/collectors/active_record"
require "nsa/collectors/active_support_cache"
require "nsa/collectors/null"
require "nsa/collectors/sidekiq"

module NSA
  module Statsd
    module Informant
      extend ::NSA::Statsd::Subscriber

      COLLECTOR_TYPES = ::Hash.new(::NSA::Collectors::Null).merge({
        :action_controller => ::NSA::Collectors::ActionController,
        :active_record => ::NSA::Collectors::ActiveRecord,
        :active_support_cache => ::NSA::Collectors::ActiveSupportCache,
        :sidekiq => ::NSA::Collectors::Sidekiq
      }).freeze

      def self.collect(collector, key_prefix)
        collector = COLLECTOR_TYPES[collector.to_sym] unless collector.respond_to?(:collect)
        collector.collect(key_prefix)
      end

      def self.listen(backend)
        statsd_subscribe(backend)
      end

    end
  end
end
