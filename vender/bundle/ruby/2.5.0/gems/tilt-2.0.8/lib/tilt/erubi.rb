require 'tilt/template'
require 'erubi'

module Tilt
  # Erubi (a simplified version of Erubis) template implementation.
  # See https://github.com/jeremyevans/erubi
  #
  # ErubiTemplate supports the following additional options, in addition
  # to the options supported by the Erubi engine:
  #
  # :engine_class :: allows you to specify a custom engine class to use
  #                  instead of the default (which is ::Erubi::Engine).
  class ErubiTemplate < Template
    def prepare
      @options.merge!(:preamble => false, :postamble => false, :ensure=>true)

      engine_class = @options[:engine_class] || Erubi::Engine

      @engine = engine_class.new(data, @options)
      @outvar = @engine.bufvar

      # Remove dup after tilt supports frozen source.
      @src = @engine.src.dup

      @engine
    end

    def precompiled_template(locals)
      @src
    end
  end
end
