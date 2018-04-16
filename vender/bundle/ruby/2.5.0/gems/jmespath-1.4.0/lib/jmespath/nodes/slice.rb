module JMESPath
  # @api private
  module Nodes
    class Slice < Node
      def initialize(start, stop, step)
        @start = start
        @stop = stop
        @step = step
        raise Errors::InvalidValueError.new('slice step cannot be 0') if @step == 0
      end

      def visit(value)
        if String === value || Array === value
          start, stop, step = adjust_slice(value.size, @start, @stop, @step)
          result = []
          if step > 0
            i = start
            while i < stop
              result << value[i]
              i += step
            end
          else
            i = start
            while i > stop
              result << value[i]
              i += step
            end
          end
          String === value ? result.join : result
        else
          nil
        end
      end

      def optimize
        if (@step.nil? || @step == 1) && @start && @stop && @start > 0 && @stop > @start
          SimpleSlice.new(@start, @stop)
        else
          self
        end
      end

      private

      def adjust_slice(length, start, stop, step)
        if step.nil?
          step = 1
        end

        if start.nil?
          start = step < 0 ? length - 1 : 0
        else
          start = adjust_endpoint(length, start, step)
        end

        if stop.nil?
          stop = step < 0 ? -1 : length
        else
          stop = adjust_endpoint(length, stop, step)
        end
        [start, stop, step]
      end

      def adjust_endpoint(length, endpoint, step)
        if endpoint < 0
          endpoint += length
          endpoint = step < 0 ? -1 : 0 if endpoint < 0
          endpoint
        elsif endpoint >= length
          step < 0 ? length - 1 : length
        else
          endpoint
        end
      end
    end

    class SimpleSlice < Slice
      def initialize(start, stop)
        super(start, stop, 1)
      end

      def visit(value)
        if String === value || Array === value
          value[@start, @stop - @start]
        else
          nil
        end
      end
    end
  end
end
