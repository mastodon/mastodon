# frozen_string_literal: true

module Mastodon::Feature
  class << self
    def enabled_features
      @enabled_features ||=
        (Rails.configuration.x.mastodon.experimental_features || '').split(',').map(&:strip)
    end

    def alt_text_ai_enabled?
      ENV['ALT_TEXT_AI_PROMPT'].present? && ENV['ALT_TEXT_AI_API_BASE'].present?
    end

    def alt_text_ai_model
      ENV.fetch('ALT_TEXT_AI_MODEL', 'google/gemma-3-4b-it')
    end

    def method_missing(name)
      if respond_to_missing?(name)
        feature = name.to_s.delete_suffix('_enabled?')
        enabled = enabled_features.include?(feature)
        define_singleton_method(name) { enabled }

        return enabled
      end

      super
    end

    def respond_to_missing?(name, include_all = false)
      name.to_s.end_with?('_enabled?') || super
    end
  end
end
