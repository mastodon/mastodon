class Thor
  module LineEditor
    class Basic
      attr_reader :prompt, :options

      def self.available?
        true
      end

      def initialize(prompt, options)
        @prompt = prompt
        @options = options
      end

      def readline
        $stdout.print(prompt)
        get_input
      end

    private

      def get_input
        if echo?
          $stdin.gets
        else
          # Lazy-load io/console since it is gem-ified as of 2.3
          require "io/console" if RUBY_VERSION > "1.9.2"
          $stdin.noecho(&:gets)
        end
      end

      def echo?
        options.fetch(:echo, true)
      end
    end
  end
end
