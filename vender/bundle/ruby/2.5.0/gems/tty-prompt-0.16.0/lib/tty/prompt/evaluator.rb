# encoding: utf-8
# frozen_string_literal: true

require_relative 'result'

module TTY
  class Prompt
    # Evaluates provided parameters and stops if any of them fails
    # @api private
    class Evaluator
      attr_reader :results

      def initialize(question, &block)
        @question = question
        @results = []
        instance_eval(&block) if block
      end

      def call(initial)
        seed = Result::Success.new(@question, initial)
        results.reduce(seed, &:with)
      end

      def check(proc = nil, &block)
        results << (proc || block)
      end
      alias_method :<<, :check
    end # Evaluator
  end # Prompt
end # TTY
