module Temple
  # An engine is simply a chain of compilers (that often includes a parser,
  # some filters and a generator).
  #
  #   class MyEngine < Temple::Engine
  #     # First run MyParser, passing the :strict option
  #     use MyParser, :strict
  #
  #     # Then a custom filter
  #     use MyFilter
  #
  #     # Then some general optimizations filters
  #     filter :MultiFlattener
  #     filter :StaticMerger
  #     filter :DynamicInliner
  #
  #     # Finally the generator
  #     generator :ArrayBuffer, :buffer
  #   end
  #
  #   class SpecialEngine < MyEngine
  #     append MyCodeOptimizer
  #     before :ArrayBuffer, Temple::Filters::Validator
  #     replace :ArrayBuffer, Temple::Generators::RailsOutputBuffer
  #   end
  #
  #   engine = MyEngine.new(strict: "For MyParser")
  #   engine.call(something)
  #
  # @api public
  class Engine
    include Mixins::Options
    include Mixins::EngineDSL
    extend  Mixins::EngineDSL

    define_options :file, :streaming, :buffer, :save_buffer

    attr_reader :chain

    def self.chain
      @chain ||= superclass.respond_to?(:chain) ? superclass.chain.dup : []
    end

    def initialize(opts = {})
      super
      @chain = self.class.chain.dup
    end

    def call(input)
      call_chain.inject(input) {|m, e| e.call(m) }
    end

    protected

    def chain_modified!
      @call_chain = nil
    end

    def call_chain
      @call_chain ||= @chain.map do |name, constructor|
        f = constructor.call(self)
        raise "Constructor #{name} must return callable object" if f && !f.respond_to?(:call)
        f
      end.compact
    end
  end
end
