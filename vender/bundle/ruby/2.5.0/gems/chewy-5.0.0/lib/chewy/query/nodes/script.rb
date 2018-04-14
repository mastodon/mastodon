module Chewy
  class Query
    module Nodes
      class Script < Expr
        def initialize(script, params = {})
          @script = script
          @params = params
          @options = params.select { |k, _v| [:cache].include?(k) }
        end

        def __render__
          script = {script: @script}
          script[:params] = @params if @params.present?
          script[:_cache] = !!@options[:cache] if @options.key?(:cache)
          {script: script}
        end
      end
    end
  end
end
