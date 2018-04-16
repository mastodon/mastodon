module Temple
  module Filters
    # Inlines several static/dynamic into a single dynamic.
    #
    # @api public
    class DynamicInliner < Filter
      def on_multi(*exps)
        result = [:multi]
        curr = nil
        prev = []
        state = :looking

        exps.each do |exp|
          type, arg = exp

          case type
          when :newline
            if state == :looking
              # We haven't found any static/dynamic, so let's just add it
              result << exp
            else
              # We've found something, so let's make sure the generated
              # dynamic contains a newline by escaping a newline and
              # starting a new string:
              #
              # "Hello "\
              # "#{@world}"
              prev << exp
              curr[1] << "\"\\\n\""
            end
          when :dynamic, :static
            case state
            when :looking
              # Found a single static/dynamic. We don't want to turn this
              # into a dynamic yet.  Instead we store it, and if we find
              # another one, we add both then.
              state = :single
              prev = [exp]
              curr = [:dynamic, '"']
            when :single
              # Yes! We found another one. Add the current dynamic to the result.
              state = :several
              result << curr
            end
            curr[1] << (type == :static ? arg.inspect[1..-2] : "\#{#{arg}}")
          else
            if state != :looking
              # We need to add the closing quote.
              curr[1] << '"'
              # If we found a single exp last time, let's add it.
              result.concat(prev) if state == :single
            end
            # Compile the current exp
            result << compile(exp)
            # Now we're looking for more!
            state = :looking
          end
        end

        if state != :looking
          # We need to add the closing quote.
          curr[1] << '"'
          # If we found a single exp last time, let's add it.
          result.concat(prev) if state == :single
        end

        result.size == 2 ? result[1] : result
      end
    end
  end
end
