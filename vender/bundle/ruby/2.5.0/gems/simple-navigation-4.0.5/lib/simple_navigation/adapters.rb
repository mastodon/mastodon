require 'simple_navigation/adapters/base'

module SimpleNavigation
  module Adapters
    autoload :Rails, 'simple_navigation/adapters/rails'
    autoload :Padrino, 'simple_navigation/adapters/padrino'
    autoload :Sinatra, 'simple_navigation/adapters/sinatra'
    autoload :Nanoc, 'simple_navigation/adapters/nanoc'
  end
end
