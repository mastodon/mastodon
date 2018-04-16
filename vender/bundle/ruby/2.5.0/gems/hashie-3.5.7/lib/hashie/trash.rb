require 'hashie/dash'
require 'hashie/extensions/dash/property_translation'

module Hashie
  # A Trash is a 'translated' Dash where the keys can be remapped from a source
  # hash.
  #
  # Trashes are useful when you need to read data from another application,
  # such as a Java api, where the keys are named differently from how we would
  # in Ruby.
  class Trash < Dash
    include Hashie::Extensions::Dash::PropertyTranslation
  end
end
