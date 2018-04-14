# coding: UTF-8

module Terrapin
  class CommandLineError < StandardError; end
  class CommandNotFoundError < CommandLineError; end
  class ExitStatusError < CommandLineError; end
  class InterpolationError < CommandLineError; end
end
