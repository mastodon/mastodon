require 'tilt/template'
require 'haml'

module Tilt
  # Haml template implementation. See:
  # http://haml.hamptoncatlin.com/
  class HamlTemplate < Template
    self.default_mime_type = 'text/html'

    # `Gem::Version.correct?` may return false because of Haml::VERSION #=> "3.1.8 (Separated Sally)". After Haml 4, it's always correct.
    if Gem::Version.correct?(Haml::VERSION) && Gem::Version.new(Haml::VERSION) >= Gem::Version.new('5.0.0.beta.2')
      def prepare
        options = {}.update(@options).update(filename: eval_file, line: line)
        if options.include?(:outvar)
          options[:buffer] = options.delete(:outvar)
          options[:save_buffer] = true
        end
        @engine = ::Haml::TempleEngine.new(options)
        @engine.compile(data)
      end

      def evaluate(scope, locals, &block)
        raise ArgumentError, 'invalid scope: must not be frozen' if scope.frozen?
        super
      end

      def precompiled_template(locals)
        @engine.precompiled_with_ambles(
          [],
          after_preamble: <<-RUBY
            __in_erb_template = true
            _haml_locals = locals
          RUBY
        )
      end
    else # Following definitions are for Haml <= 4 and deprecated.
      def prepare
        options = @options.merge(:filename => eval_file, :line => line)
        @engine = ::Haml::Engine.new(data, options)
      end

      def evaluate(scope, locals, &block)
        raise ArgumentError, 'invalid scope: must not be frozen' if scope.frozen?

        if @engine.respond_to?(:precompiled_method_return_value, true)
          super
        else
          @engine.render(scope, locals, &block)
        end
      end

      # Precompiled Haml source. Taken from the precompiled_with_ambles
      # method in Haml::Precompiler:
      # http://github.com/nex3/haml/blob/master/lib/haml/precompiler.rb#L111-126
      def precompiled_template(locals)
        @engine.precompiled
      end

      def precompiled_preamble(locals)
        local_assigns = super
        @engine.instance_eval do
          <<-RUBY
            begin
              extend Haml::Helpers
              _hamlout = @haml_buffer = Haml::Buffer.new(@haml_buffer, #{options_for_buffer.inspect})
              _erbout = _hamlout.buffer
              __in_erb_template = true
              _haml_locals = locals
              #{local_assigns}
          RUBY
        end
      end

      def precompiled_postamble(locals)
        @engine.instance_eval do
          <<-RUBY
              #{precompiled_method_return_value}
            ensure
              @haml_buffer = @haml_buffer.upper if @haml_buffer
            end
          RUBY
        end
      end
    end
  end
end
