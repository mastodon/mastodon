require 'sprockets'

module Sprockets
  module Rails
    module Utils
      def using_sprockets4?
        Gem::Version.new(Sprockets::VERSION) >= Gem::Version.new('4.x')
      end
    end
  end
end
