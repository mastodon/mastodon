# frozen_string_literal: true
module Excon
  class PrettyPrinter
    def self.pp(io, datum, indent=0)
      datum = datum.dup

      # reduce duplication/noise of output
      unless datum.is_a?(Excon::Headers)
        datum.delete(:connection)
        datum.delete(:stack)

        if datum.has_key?(:headers) && datum[:headers].has_key?('Authorization')
          datum[:headers] = datum[:headers].dup
          datum[:headers]['Authorization'] = REDACTED
        end

        if datum.has_key?(:password)
          datum[:password] = REDACTED
        end
      end

      indent += 2
      max_key_length = datum.keys.map {|key| key.inspect.length}.max
      datum.keys.sort_by {|key| key.to_s}.each do |key|
        value = datum[key]
        io.write("#{' ' * indent}#{key.inspect.ljust(max_key_length)} => ")
        case value
        when Array
          io.puts("[")
          value.each do |v|
            io.puts("#{' ' * indent}  #{v.inspect}")
          end
          io.write("#{' ' * indent}]")
        when Hash
          io.puts("{")
          self.pp(io, value, indent)
          io.write("#{' ' * indent}}")
        else
          io.write("#{value.inspect}")
        end
        io.puts
      end
      indent -= 2
    end
  end
end
