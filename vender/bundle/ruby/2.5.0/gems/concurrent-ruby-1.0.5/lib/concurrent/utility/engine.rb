module Concurrent
  module Utility

    # @!visibility private
    module EngineDetector
      def on_jruby?
        ruby_engine == 'jruby'
      end

      def on_jruby_9000?
        on_jruby? && ruby_version(:>=, 9, 0, 0, JRUBY_VERSION)
      end

      def on_cruby?
        ruby_engine == 'ruby'
      end

      def on_rbx?
        ruby_engine == 'rbx'
      end

      def on_truffle?
        ruby_engine == 'jruby+truffle'
      end

      def on_windows?
        !(RbConfig::CONFIG['host_os'] =~ /mswin|mingw|cygwin/).nil?
      end

      def on_osx?
        !(RbConfig::CONFIG['host_os'] =~ /darwin|mac os/).nil?
      end

      def on_linux?
        !(RbConfig::CONFIG['host_os'] =~ /linux/).nil?
      end

      def ruby_engine
        defined?(RUBY_ENGINE) ? RUBY_ENGINE : 'ruby'
      end

      def ruby_version(comparison, major, minor, patch, version = RUBY_VERSION)
        result      = (version.split('.').map(&:to_i) <=> [major, minor, patch])
        comparisons = { :== => [0],
                        :>= => [1, 0],
                        :<= => [-1, 0],
                        :>  => [1],
                        :<  => [-1] }
        comparisons.fetch(comparison).include? result
      end
    end
  end

  # @!visibility private
  extend Utility::EngineDetector
end
