# frozen_string_literal: true

module JsonLdHelper
  def equals_or_includes?(haystack, needle)
    haystack.is_a?(Array) ? haystack.include?(needle) : haystack == needle
  end

  def supported_context?(json)
    equals_or_includes?(json['@context'], ActivityPub::TagManager::CONTEXT)
  end
end
