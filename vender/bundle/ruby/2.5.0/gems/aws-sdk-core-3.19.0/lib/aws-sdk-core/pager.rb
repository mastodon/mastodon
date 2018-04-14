require 'jmespath'

module Aws
  # @api private
  class Pager

    # @option options [required, Hash<JMESPath,JMESPath>] :tokens
    # @option options [String<JMESPath>] :limit_key
    # @option options [String<JMESPath>] :more_results
    def initialize(options)
      @tokens = options.fetch(:tokens)
      @limit_key = options.fetch(:limit_key, nil)
      @more_results = options.fetch(:more_results, nil)
    end

    # @return [Symbol, nil]
    attr_reader :limit_key

    # @param [Seahorse::Client::Response] response
    # @return [Hash]
    def next_tokens(response)
      @tokens.each.with_object({}) do |(source, target), next_tokens|
        value = JMESPath.search(source, response.data)
        next_tokens[target.to_sym] = value unless empty_value?(value)
      end
    end

    # @api private
    def prev_tokens(response)
      @tokens.each.with_object({}) do |(_, target), tokens|
        value = JMESPath.search(target, response.context.params)
        tokens[target.to_sym] = value unless empty_value?(value)
      end
    end

    # @param [Seahorse::Client::Response] response
    # @return [Boolean]
    def truncated?(response)
      if @more_results
        JMESPath.search(@more_results, response.data)
      else
        next_t = next_tokens(response)
        prev_t = prev_tokens(response)
        !(next_t.empty? || next_t == prev_t)
      end
    end

    private

    def empty_value?(value)
      value.nil? || value == '' || value == [] || value == {}
    end

    class NullPager

      # @return [nil]
      attr_reader :limit_key

      def next_tokens
        {}
      end

      def prev_tokens
        {}
      end

      def truncated?(response)
        false
      end

    end
  end
end
