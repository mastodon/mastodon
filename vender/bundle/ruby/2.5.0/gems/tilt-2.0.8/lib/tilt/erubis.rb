require 'tilt/erb'
require 'erubis'

module Tilt
  # Erubis template implementation. See:
  # http://www.kuwata-lab.com/erubis/
  #
  # ErubisTemplate supports the following additional options, which are not
  # passed down to the Erubis engine:
  #
  #   :engine_class   allows you to specify a custom engine class to use
  #                   instead of the default (which is ::Erubis::Eruby).
  #
  #   :escape_html    when true, ::Erubis::EscapedEruby will be used as
  #                   the engine class instead of the default. All content
  #                   within <%= %> blocks will be automatically html escaped.
  class ErubisTemplate < ERBTemplate
    def prepare
      @outvar = options.delete(:outvar) || self.class.default_output_variable
      @options.merge!(:preamble => false, :postamble => false, :bufvar => @outvar)
      engine_class = options.delete(:engine_class)
      engine_class = ::Erubis::EscapedEruby if options.delete(:escape_html)
      @engine = (engine_class || ::Erubis::Eruby).new(data, options)
    end

    def precompiled_preamble(locals)
      [super, "#{@outvar} = _buf = String.new"].join("\n")
    end

    def precompiled_postamble(locals)
      [@outvar, super].join("\n")
    end

    # Erubis doesn't have ERB's line-off-by-one under 1.9 problem.
    # Override and adjust back.
    if RUBY_VERSION >= '1.9.0'
      def precompiled(locals)
        source, offset = super
        [source, offset - 1]
      end
    end
  end
end
