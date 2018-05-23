# encoding: utf-8

require_relative 'converter'

module Necromancer
  # A pass through converter
  class NullConverter < Converter
    def call(value, options = {})
      value
    end
  end # NullConverter
end # Necromancer
