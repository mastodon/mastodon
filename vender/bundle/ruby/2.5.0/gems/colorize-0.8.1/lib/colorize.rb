require File.expand_path('colorize/class_methods', File.dirname(__FILE__))
require File.expand_path('colorize/instance_methods', File.dirname(__FILE__))
#
# String class extension.
#
class String
  extend Colorize::ClassMethods
  include Colorize::InstanceMethods

  color_methods
  modes_methods
end
