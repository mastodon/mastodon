module Sprockets
  class Deprecation
    THREAD_LOCAL__SILENCE_KEY = "_sprockets_deprecation_silence".freeze
    DEFAULT_BEHAVIORS = {
      raise: ->(message, callstack) {
        e = DeprecationException.new(message)
        e.set_backtrace(callstack.map(&:to_s))
        raise e
      },

      stderr: ->(message, callstack) {
        $stderr.puts(message)
      },
    }

    attr_reader :callstack

    def self.silence(&block)
      Thread.current[THREAD_LOCAL__SILENCE_KEY] = true
      block.call
    ensure
      Thread.current[THREAD_LOCAL__SILENCE_KEY] = false
    end

    def initialize(callstack = nil)
      @callstack = callstack || caller(2)
    end

    def warn(message)
      return if Thread.current[THREAD_LOCAL__SILENCE_KEY]
      deprecation_message(message).tap do |m|
        behavior.each { |b| b.call(m, callstack) }
      end
    end

    private
      def behavior
        @behavior ||= [DEFAULT_BEHAVIORS[:stderr]]
      end

      def behavior=(behavior)
        @behavior = Array(behavior).map { |b| DEFAULT_BEHAVIORS[b] || b }
      end

      def deprecation_message(message = nil)
        message ||= "You are using deprecated behavior which will be removed from the next major or minor release."
        "DEPRECATION WARNING: #{message} #{ deprecation_caller_message }"
      end

      def deprecation_caller_message
        file, line, method = extract_callstack
        if file
          if line && method
            "(called from #{method} at #{file}:#{line})"
          else
            "(called from #{file}:#{line})"
          end
        end
      end

      SPROCKETS_GEM_ROOT = File.expand_path("../../../../..", __FILE__) + "/"

      def ignored_callstack(path)
        path.start_with?(SPROCKETS_GEM_ROOT) || path.start_with?(RbConfig::CONFIG['rubylibdir'])
      end

      def extract_callstack
        return _extract_callstack if callstack.first.is_a? String

        offending_line = callstack.find { |frame|
          frame.absolute_path && !ignored_callstack(frame.absolute_path)
        } || callstack.first

        [offending_line.path, offending_line.lineno, offending_line.label]
      end

      def _extract_callstack
        offending_line = callstack.find { |line| !ignored_callstack(line) } || callstack.first

        if offending_line
          if md = offending_line.match(/^(.+?):(\d+)(?::in `(.*?)')?/)
            md.captures
          else
            offending_line
          end
        end
      end
  end
  private_constant :Deprecation
end
