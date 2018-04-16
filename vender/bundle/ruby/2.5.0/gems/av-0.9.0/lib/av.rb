require "av/version"
require "av/exceptions"
require "av/logger"
require "av/cli"
require "av/param_hash"
require "av/commands/ffmpeg"
require "av/commands/avconv"
require "cocaine"
require "av/engine" if defined?(Rails)

module Av
  extend self
  extend Logger
  
  def options
    @options ||= {
      log: true,
      quiet: true,
    }
  end
  
  def cli(options = {})
    @options = options unless options.empty?
    ::Av::Cli.new(options)
  end
  
  def run line, codes = [0]
    ::Av.log("Running command: #{line}")
    begin
      Cocaine::CommandLine.new(line, "", expected_outcodes: codes).run
    rescue Cocaine::ExitStatusError => e
      raise Av::CommandError, "error while running command #{line}: #{e}"
    end
  end
end