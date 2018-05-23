require 'hashie/extensions/ruby_version'

module Hashie
  module Extensions
    module RubyVersionCheck
      def self.included(base)
        base.extend ClassMethods
      end

      module ClassMethods
        def with_minimum_ruby(version)
          yield if RubyVersion.new(RUBY_VERSION) >= RubyVersion.new(version)
        end
      end
    end
  end
end
