require File.expand_path('colorize/class_methods', File.dirname(__FILE__))
require File.expand_path('colorize/instance_methods', File.dirname(__FILE__))
#
# ColorizedString class extension.
#
class ColorizedString < String
  extend Colorize::ClassMethods
  include Colorize::InstanceMethods

  color_methods
  modes_methods

  #
  # Sortcut to create ColorizedString with ColorizedString['test'].
  #
  def self.[](string)
    ColorizedString.new(string)
  end
end
