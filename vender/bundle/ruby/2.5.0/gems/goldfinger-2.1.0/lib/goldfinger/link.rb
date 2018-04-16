# frozen_string_literal: true

module Goldfinger
  # @!attribute [r] href
  #   @return [String] The href the link points to
  # @!attribute [r] template
  #   @return [String] The template the link contains
  # @!attribute [r] type
  #   @return [String] The mime type of the link
  # @!attribute [r] rel
  #   @return [String] The relation descriptor of the link
  class Link
    attr_reader :href, :template, :type, :rel

    def initialize(a)
      @href       = a[:href]
      @template   = a[:template]
      @type       = a[:type]
      @rel        = a[:rel]
      @titles     = a[:titles]
      @properties = a[:properties]
    end

    # The "titles" object comprises zero or more name/value pairs whose
    # names are a language tag or the string "und".  The string is
    # human-readable and describes the link relation.
    # @see #title
    # @return [Array] Array form of the hash
    def titles
      @titles.to_a
    end

    #  The "properties" object within the link relation object comprises
    # zero or more name/value pairs whose names are URIs (referred to as
    # "property identifiers") and whose values are strings or nil.
    # Properties are used to convey additional information about the link
    # relation.
    # @see #property
    # @return [Array] Array form of the hash
    def properties
      @properties.to_a
    end

    # Returns a title for a language
    # @param lang [String]
    # @return [String]
    def title(lang)
      @titles[lang]
    end

    # Returns a property for a key
    # @param key [String]
    # @return [String]
    def property(key)
      @properties[key]
    end
  end
end
