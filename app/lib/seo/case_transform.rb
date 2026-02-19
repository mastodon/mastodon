# frozen_string_literal: true

module SEO::CaseTransform
  PREFIX_KEYS = %w(
    context
    id
    type
  ).freeze

  class << self
    def camel_lower_cache
      @camel_lower_cache ||= {}
    end

    def camel_lower(value)
      case value
      when Array
        value.map { |item| camel_lower(item) }
      when Hash
        value.deep_transform_keys! { |key| camel_lower(key) }
      when Symbol
        camel_lower(value.to_s).to_sym
      when String
        camel_lower_cache[value] ||= begin
          if PREFIX_KEYS.include?(value.to_s)
            "@#{value}"
          else
            value.underscore.camelize(:lower)
          end
        end
      else
        value
      end
    end
  end
end
