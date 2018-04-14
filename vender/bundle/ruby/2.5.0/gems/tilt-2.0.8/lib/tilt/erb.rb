require 'tilt/template'
require 'erb'

module Tilt
  # ERB template implementation. See:
  # http://www.ruby-doc.org/stdlib/libdoc/erb/rdoc/classes/ERB.html
  class ERBTemplate < Template
    @@default_output_variable = '_erbout'

    def self.default_output_variable
      @@default_output_variable
    end

    def self.default_output_variable=(name)
      warn "#{self}.default_output_variable= has been replaced with the :outvar-option"
      @@default_output_variable = name
    end

    def prepare
      @outvar = options[:outvar] || self.class.default_output_variable
      options[:trim] = '<>' if !(options[:trim] == false) && (options[:trim].nil? || options[:trim] == true)
      @engine = ::ERB.new(data, options[:safe], options[:trim], @outvar)
    end

    def precompiled_template(locals)
      source = @engine.src
      source
    end

    def precompiled_preamble(locals)
      <<-RUBY
        begin
          __original_outvar = #{@outvar} if defined?(#{@outvar})
          #{super}
      RUBY
    end

    def precompiled_postamble(locals)
      <<-RUBY
          #{super}
        ensure
          #{@outvar} = __original_outvar
        end
      RUBY
    end

    # ERB generates a line to specify the character coding of the generated
    # source in 1.9. Account for this in the line offset.
    if RUBY_VERSION >= '1.9.0'
      def precompiled(locals)
        source, offset = super
        [source, offset + 1]
      end
    end
  end
end

