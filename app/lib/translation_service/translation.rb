# frozen_string_literal: true

class TranslationService::Translation < ActiveModelSerializers::Model
  attributes :text, :detected_source_language, :provider
end
