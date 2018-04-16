# encoding: utf-8
# frozen_string_literal: true

require_relative 'abstract'

module TTY
  class Command
    module Printers
      class Null < Abstract
        def write(*)
          # Do nothing
        end
      end # Null
    end # Printers
  end # Command
end # TTY
