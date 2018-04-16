module Rack
  module Auth
    module Digest
      class Params < Hash

        def self.parse(str)
          Params[*split_header_value(str).map do |param|
            k, v = param.split('=', 2)
            [k, dequote(v)]
          end.flatten]
        end

        def self.dequote(str) # From WEBrick::HTTPUtils
          ret = (/\A"(.*)"\Z/ =~ str) ? $1 : str.dup
          ret.gsub!(/\\(.)/, "\\1")
          ret
        end

        def self.split_header_value(str)
          str.scan(/\w+\=(?:"[^\"]+"|[^,]+)/n)
        end

        def initialize
          super()

          yield self if block_given?
        end

        def [](k)
          super k.to_s
        end

        def []=(k, v)
          super k.to_s, v.to_s
        end

        UNQUOTED = ['nc', 'stale']

        def to_s
          map do |k, v|
            "#{k}=" << (UNQUOTED.include?(k) ? v.to_s : quote(v))
          end.join(', ')
        end

        def quote(str) # From WEBrick::HTTPUtils
          '"' << str.gsub(/[\\\"]/o, "\\\1") << '"'
        end

      end
    end
  end
end
