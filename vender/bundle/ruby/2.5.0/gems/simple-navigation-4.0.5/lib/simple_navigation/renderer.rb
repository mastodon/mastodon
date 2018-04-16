require 'simple_navigation/helpers'
require 'simple_navigation/renderer/base'

module SimpleNavigation
  module Renderer
    autoload :List, 'simple_navigation/renderer/list'
    autoload :Links, 'simple_navigation/renderer/links'
    autoload :Breadcrumbs, 'simple_navigation/renderer/breadcrumbs'
    autoload :Text, 'simple_navigation/renderer/text'
    autoload :Json, 'simple_navigation/renderer/json'
  end
end
