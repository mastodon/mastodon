require "dotenv/parser"
require "dotenv/environment"

# The top level Dotenv module. The entrypoint for the application logic.
module Dotenv
  class << self
    attr_accessor :instrumenter
  end

  module_function

  def load(*filenames)
    with(*filenames) do |f|
      ignoring_nonexistent_files do
        env = Environment.new(f)
        instrument("dotenv.load", env: env) { env.apply }
      end
    end
  end

  # same as `load`, but raises Errno::ENOENT if any files don't exist
  def load!(*filenames)
    with(*filenames) do |f|
      env = Environment.new(f)
      instrument("dotenv.load", env: env) { env.apply }
    end
  end

  # same as `load`, but will override existing values in `ENV`
  def overload(*filenames)
    with(*filenames) do |f|
      ignoring_nonexistent_files do
        env = Environment.new(f)
        instrument("dotenv.overload", env: env) { env.apply! }
      end
    end
  end

  # Internal: Helper to expand list of filenames.
  #
  # Returns a hash of all the loaded environment variables.
  def with(*filenames)
    filenames << ".env" if filenames.empty?

    filenames.reduce({}) do |hash, filename|
      hash.merge!(yield(File.expand_path(filename)) || {})
    end
  end

  def instrument(name, payload = {}, &block)
    if instrumenter
      instrumenter.instrument(name, payload, &block)
    else
      yield
    end
  end

  def ignoring_nonexistent_files
    yield
  rescue Errno::ENOENT
  end
end
