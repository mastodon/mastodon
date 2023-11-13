# frozen_string_literal: true

module ActivityPub::CaseTransform
  class << self
    def camel_lower_cache
      @camel_lower_cache ||= {}
    end

    def camel_lower(value)
      case value
      when Array then value.map { |item| camel_lower(item) }
      when Hash then value.deep_transform_keys! { |key| camel_lower(key) }
      when Symbol then camel_lower(value.to_s).to_sym
      when String
        camel_lower_cache[value] ||= if value.start_with?('_:')
                                       "_:#{value.delete_prefix('_:').underscore.camelize(:lower)}"
                                     elsif LanguagesHelper::ISO_639_1_REGIONAL.key?(value.to_sym)
                                       value
                                     else
                                       value.underscore.camelize(:lower)
                                     end
      else value
      end
    end
  end
end
