module Temple
  module Generators
    # Just like Array, but calls #join on the array.
    #
    #   _buf = []
    #   _buf << "static"
    #   _buf << dynamic
    #   _buf.join("")
    #
    # @api public
    class ArrayBuffer < Array
      def call(exp)
        case exp.first
        when :static
          [save_buffer, "#{buffer} = #{exp.last.inspect}", restore_buffer].compact.join('; ')
        when :dynamic
          [save_buffer, "#{buffer} = (#{exp.last}).to_s", restore_buffer].compact.join('; ')
        else
          super
        end
      end

      def return_buffer
        freeze = options[:freeze_static] ? '.freeze' : ''
        "#{buffer} = #{buffer}.join(\"\"#{freeze})"
      end
    end
  end
end
