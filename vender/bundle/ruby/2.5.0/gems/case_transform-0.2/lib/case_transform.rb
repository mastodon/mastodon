# frozen_string_literal: true
require 'active_support/core_ext/hash/keys'
require 'active_support/core_ext/string'

require 'case_transform/version'

module CaseTransform
  class << self
    def camel_cache
      @camel_cache ||= {}
    end

    def camel_lower_cache
      @camel_lower_cache ||= {}
    end

    def dash_cache
      @dash_cache ||= {}
    end

    def underscore_cache
      @underscore_cache ||= {}
    end

    # Transforms values to UpperCamelCase or PascalCase.
    #
    # @example:
    #    "some_key" => "SomeKey",
    def camel(value)
      case value
      when Array then value.map { |item| camel(item) }
      when Hash then value.deep_transform_keys! { |key| camel(key) }
      when Symbol then camel(value.to_s).to_sym
      when String then camel_cache[value] ||= value.underscore.camelize
      else value
      end
    end

    # Transforms values to camelCase.
    #
    # @example:
    #    "some_key" => "someKey",
    def camel_lower(value)
      case value
      when Array then value.map { |item| camel_lower(item) }
      when Hash then value.deep_transform_keys! { |key| camel_lower(key) }
      when Symbol then camel_lower(value.to_s).to_sym
      when String then camel_lower_cache[value] ||= value.underscore.camelize(:lower)
      else value
      end
    end

    # Transforms values to dashed-case.
    # This is the default case for the JsonApi adapter.
    #
    # @example:
    #    "some_key" => "some-key",
    def dash(value)
      case value
      when Array then value.map { |item| dash(item) }
      when Hash then value.deep_transform_keys! { |key| dash(key) }
      when Symbol then dash(value.to_s).to_sym
      when String then dash_cache[value] ||= value.underscore.dasherize
      else value
      end
    end

    # Transforms values to underscore_case.
    # This is the default case for deserialization in the JsonApi adapter.
    #
    # @example:
    #    "some-key" => "some_key",
    def underscore(value)
      case value
      when Array then value.map { |item| underscore(item) }
      when Hash then value.deep_transform_keys! { |key| underscore(key) }
      when Symbol then underscore(value.to_s).to_sym
      when String then underscore_cache[value] ||= value.underscore
      else value
      end
    end

    # Returns the value unaltered
    def unaltered(value)
      value
    end
  end
end
