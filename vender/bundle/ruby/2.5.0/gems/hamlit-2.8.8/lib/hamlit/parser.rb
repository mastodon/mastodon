# frozen_string_literal: true
# Hamlit::Parser uses original Haml::Parser to generate Haml AST.
# hamlit/parser/haml_* are modules originally in haml gem.

require 'hamlit/parser/haml_error'
require 'hamlit/parser/haml_util'
require 'hamlit/parser/haml_buffer'
require 'hamlit/parser/haml_compiler'
require 'hamlit/parser/haml_parser'
require 'hamlit/parser/haml_helpers'
require 'hamlit/parser/haml_options'

module Hamlit
  class Parser
    AVAILABLE_OPTIONS = %i[
      autoclose
      escape_html
      escape_attrs
    ].freeze

    def initialize(options = {})
      @options = HamlOptions.defaults.dup
      AVAILABLE_OPTIONS.each do |key|
        @options[key] = options[key]
      end
    end

    def call(template)
      HamlParser.new(template, HamlOptions.new(@options)).parse
    rescue ::Hamlit::HamlError => e
      error_with_lineno(e)
    end

    private

    def error_with_lineno(error)
      return error if error.line

      trace = error.backtrace.first
      return error unless trace

      line = trace.match(/\d+\z/).to_s.to_i
      HamlSyntaxError.new(error.message, line)
    end
  end
end
