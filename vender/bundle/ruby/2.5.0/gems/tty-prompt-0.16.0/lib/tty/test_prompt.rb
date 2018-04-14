# encoding: utf-8
# frozen_string_literal: true

require_relative 'prompt'

module TTY
  # Used for initializing test cases
  class TestPrompt < Prompt
    def initialize(options = {})
      @input  = StringIO.new
      @output = StringIO.new
      options.merge!({
        input: @input,
        output: @output,
        env: { "TTY_TEST" => true },
        enable_color: options.fetch(:enable_color) { true }
      })
      super(options)
    end
  end # TestPrompt
end # TTY
