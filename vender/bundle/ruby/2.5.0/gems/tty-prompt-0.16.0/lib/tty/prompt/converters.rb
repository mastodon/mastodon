# encoding: utf-8
# frozen_string_literal: true

require 'pathname'
require 'necromancer'

require_relative 'converter_dsl'

module TTY
  class Prompt
    module Converters
      extend ConverterDSL

      # Delegate Necromancer errors
      #
      # @api private
      def self.on_error
        if block_given?
          yield
        else
          raise ArgumentError, 'You need to provide a block argument.'
        end
      rescue Necromancer::ConversionTypeError => e
        raise ConversionError, e.message
      end

      converter(:bool) do |input|
        on_error { Necromancer.convert(input).to(:boolean, strict: true) }
      end

      converter(:string) do |input|
        String(input).chomp
      end

      converter(:symbol) do |input|
        input.to_sym
      end

      converter(:date) do |input|
        on_error { Necromancer.convert(input).to(:date, strict: true) }
      end

      converter(:datetime) do |input|
        on_error { Necromancer.convert(input).to(:datetime, strict: true) }
      end

      converter(:int) do |input|
        on_error { Necromancer.convert(input).to(:integer, strict: true) }
      end

      converter(:float) do |input|
        on_error { Necromancer.convert(input).to(:float, strict: true) }
      end

      converter(:range) do |input|
        on_error { Necromancer.convert(input).to(:range, strict: true) }
      end

      converter(:regexp) do |input|
        Regexp.new(input)
      end

      converter(:file) do |input|
        ::File.open(::File.join(Dir.pwd, input))
      end

      converter(:path) do |input|
        Pathname.new(::File.join(Dir.pwd, input))
      end

      converter(:char) do |input|
        String(input).chars.to_a[0]
      end
    end # Converters
  end # Prompt
end # TTY
