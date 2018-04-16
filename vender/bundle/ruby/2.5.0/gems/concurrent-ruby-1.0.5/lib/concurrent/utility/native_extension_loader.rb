require 'concurrent/utility/engine'

module Concurrent

  module Utility

    # @!visibility private
    module NativeExtensionLoader

      def allow_c_extensions?
        Concurrent.on_cruby?
      end

      def c_extensions_loaded?
        @c_extensions_loaded ||= false
      end

      def java_extensions_loaded?
        @java_extensions_loaded ||= false
      end

      def set_c_extensions_loaded
        @c_extensions_loaded = true
      end

      def set_java_extensions_loaded
        @java_extensions_loaded = true
      end

      def load_native_extensions
        unless defined? Synchronization::AbstractObject
          raise 'native_extension_loader loaded before Synchronization::AbstractObject'
        end

        if Concurrent.on_cruby? && !c_extensions_loaded?
          tries = [
            lambda do
              require 'concurrent/extension'
              set_c_extensions_loaded
            end,
            lambda do
              # may be a Windows cross-compiled native gem
              require "concurrent/#{RUBY_VERSION[0..2]}/extension"
              set_c_extensions_loaded
            end]

          tries.each do |try|
            begin
              try.call
              break
            rescue LoadError
              next
            end
          end
        end

        if Concurrent.on_jruby? && !java_extensions_loaded?
          begin
            require 'concurrent_ruby_ext'
            set_java_extensions_loaded
          rescue LoadError
            # move on with pure-Ruby implementations
            raise 'On JRuby but Java extensions failed to load.'
          end
        end
      end
    end
  end

  # @!visibility private
  extend Utility::NativeExtensionLoader
end

