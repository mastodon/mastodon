module Chewy
  class Query
    module Nodes
      class Bool < Expr
        METHODS = %w[must must_not should].freeze

        def initialize(options = {})
          @options = options
          @must = []
          @must_not = []
          @should = []
        end

        METHODS.each do |method|
          define_method method do |*exprs|
            instance_variable_get("@#{method}").concat(exprs)
            self
          end
        end

        def __render__
          bool = {
            bool: Hash[METHODS.map do |method|
              value = instance_variable_get("@#{method}")
              [method.to_sym, value.map(&:__render__)] if value.present?
            end.compact]
          }
          bool[:bool][:_cache] = !!@options[:cache] if @options.key?(:cache)
          bool
        end
      end
    end
  end
end
