module Rack
  class Attack
    class Throttle
      MANDATORY_OPTIONS = [:limit, :period].freeze

      attr_reader :name, :limit, :period, :block, :type
      def initialize(name, options, block)
        @name, @block = name, block
        MANDATORY_OPTIONS.each do |opt|
          raise ArgumentError.new("Must pass #{opt.inspect} option") unless options[opt]
        end
        @limit  = options[:limit]
        @period = options[:period].respond_to?(:call) ? options[:period] : options[:period].to_i
        @type   = options.fetch(:type, :throttle)
      end

      def cache
        Rack::Attack.cache
      end

      def [](req)
        discriminator = block[req]
        return false unless discriminator

        current_period = period.respond_to?(:call) ? period.call(req) : period
        current_limit  = limit.respond_to?(:call) ? limit.call(req) : limit
        key            = "#{name}:#{discriminator}"
        count          = cache.count(key, current_period)

        data = {
          :count => count,
          :period => current_period,
          :limit => current_limit
        }
        (req.env['rack.attack.throttle_data'] ||= {})[name] = data

        (count > current_limit).tap do |throttled|
          if throttled
            req.env['rack.attack.matched']             = name
            req.env['rack.attack.match_discriminator'] = discriminator
            req.env['rack.attack.match_type']          = type
            req.env['rack.attack.match_data']          = data
            Rack::Attack.instrument(req)
          end
        end
      end
    end
  end
end
