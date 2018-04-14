begin
  require "readline"
rescue LoadError
end

class Thor
  module LineEditor
    class Readline < Basic
      def self.available?
        Object.const_defined?(:Readline)
      end

      def readline
        if echo?
          ::Readline.completion_append_character = nil
          # Ruby 1.8.7 does not allow Readline.completion_proc= to receive nil.
          if complete = completion_proc
            ::Readline.completion_proc = complete
          end
          ::Readline.readline(prompt, add_to_history?)
        else
          super
        end
      end

    private

      def add_to_history?
        options.fetch(:add_to_history, true)
      end

      def completion_proc
        if use_path_completion?
          proc { |text| PathCompletion.new(text).matches }
        elsif completion_options.any?
          proc do |text|
            completion_options.select { |option| option.start_with?(text) }
          end
        end
      end

      def completion_options
        options.fetch(:limited_to, [])
      end

      def use_path_completion?
        options.fetch(:path, false)
      end

      class PathCompletion
        attr_reader :text
        private :text

        def initialize(text)
          @text = text
        end

        def matches
          relative_matches
        end

      private

        def relative_matches
          absolute_matches.map { |path| path.sub(base_path, "") }
        end

        def absolute_matches
          Dir[glob_pattern].map do |path|
            if File.directory?(path)
              "#{path}/"
            else
              path
            end
          end
        end

        def glob_pattern
          "#{base_path}#{text}*"
        end

        def base_path
          "#{Dir.pwd}/"
        end
      end
    end
  end
end
