require 'stringio'

module Aws
  module Query
    class ParamList

      include Enumerable

      # @api private
      def initialize
        @params = {}
      end

      # @param [String] param_name
      # @param [String, nil] param_value
      # @return [Param]
      def set(param_name, param_value = nil)
        param = Param.new(param_name, param_value)
        @params[param.name] = param
        param
      end
      alias []= set

      # @return [Param, nil]
      def [](param_name)
        @params[param_name.to_s]
      end

      # @param [String] param_name
      # @return [Param, nil]
      def delete(param_name)
        @params.delete(param_name)
      end

      # @return [Enumerable]
      def each(&block)
        to_a.each(&block)
      end

      # @return [Boolean]
      def empty?
        @params.empty?
      end

      # @return [Array<Param>] Returns an array of sorted {Param} objects.
      def to_a
        @params.values.sort
      end

      # @return [String]
      def to_s
        to_a.map(&:to_s).join('&')
      end

      # @return [#read, #rewind, #size]
      def to_io
        IoWrapper.new(self)
      end

      # @api private
      class IoWrapper

        # @param [ParamList] param_list
        def initialize(param_list)
          @param_list = param_list
          @io = StringIO.new(param_list.to_s)
        end

        # @return [ParamList]
        attr_reader :param_list

        # @return [Integer]
        def size
          @io.size
        end

        # @return [void]
        def rewind
          @io.rewind
        end

        # @return [String, nil]
        def read(bytes = nil, output_buffer = nil)
          @io.read(bytes, output_buffer)
        end

      end

    end
  end
end
