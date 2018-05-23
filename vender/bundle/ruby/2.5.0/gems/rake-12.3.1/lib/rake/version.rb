# frozen_string_literal: true
module Rake
  VERSION = "12.3.1"

  module Version # :nodoc: all
    MAJOR, MINOR, BUILD, *OTHER = Rake::VERSION.split "."

    NUMBERS = [MAJOR, MINOR, BUILD, *OTHER]
  end
end
