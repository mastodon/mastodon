require 'strscan'

module WebSocket
  class Extensions

    class Parser
      TOKEN    = /([!#\$%&'\*\+\-\.\^_`\|~0-9A-Za-z]+)/
      NOTOKEN  = /([^!#\$%&'\*\+\-\.\^_`\|~0-9A-Za-z])/
      QUOTED   = /"((?:\\[\x00-\x7f]|[^\x00-\x08\x0a-\x1f\x7f"])*)"/
      PARAM    = %r{#{TOKEN.source}(?:=(?:#{TOKEN.source}|#{QUOTED.source}))?}
      EXT      = %r{#{TOKEN.source}(?: *; *#{PARAM.source})*}
      EXT_LIST = %r{^#{EXT.source}(?: *, *#{EXT.source})*$}
      NUMBER   = /^-?(0|[1-9][0-9]*)(\.[0-9]+)?$/

      ParseError = Class.new(ArgumentError)

      def self.parse_header(header)
        offers = Offers.new
        return offers if header == '' or header.nil?

        unless header =~ EXT_LIST
          raise ParseError, "Invalid Sec-WebSocket-Extensions header: #{header}"
        end

        scanner = StringScanner.new(header)
        value   = scanner.scan(EXT)

        until value.nil?
          params = value.scan(PARAM)
          name   = params.shift.first
          offer  = {}

          params.each do |key, unquoted, quoted|
            if unquoted
              data = unquoted
            elsif quoted
              data = quoted.gsub(/\\/, '')
            else
              data = true
            end
            if data =~ NUMBER
              data = data =~ /\./ ? data.to_f : data.to_i(10)
            end

            if offer.has_key?(key)
              offer[key] = [*offer[key]] + [data]
            else
              offer[key] = data
            end
          end

          offers.push(name, offer)

          scanner.scan(/ *, */)
          value = scanner.scan(EXT)
        end
        offers
      end

      def self.serialize_params(name, params)
        values = []

        print = lambda do |key, value|
          case value
          when Array   then value.each { |v| print[key, v] }
          when true    then values.push(key)
          when Numeric then values.push(key + '=' + value.to_s)
          else
            if value =~ NOTOKEN
              values.push(key + '="' + value.gsub(/"/, '\"') + '"')
            else
              values.push(key + '=' + value)
            end
          end
        end

        params.keys.sort.each { |key| print[key, params[key]] }

        ([name] + values).join('; ')
      end
    end

    class Offers
      def initialize
        @by_name  = {}
        @in_order = []
      end

      def push(name, params)
        @by_name[name] ||= []
        @by_name[name].push(params)
        @in_order.push(:name => name, :params => params)
      end

      def each_offer(&block)
        @in_order.each do |offer|
          block.call(offer[:name], offer[:params])
        end
      end

      def by_name(name)
        @by_name[name] || []
      end

      def to_a
        @in_order.dup
      end
    end

  end
end
