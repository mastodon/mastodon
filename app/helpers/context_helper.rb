# frozen_string_literal: true

module ContextHelper
  NAMED_CONTEXT_MAP = {
    activitystreams: 'https://www.w3.org/ns/activitystreams',
    security: 'https://w3id.org/security/v1',
  }.freeze

  CONTEXT_EXTENSION_MAP = {
    manually_approves_followers: { 'manuallyApprovesFollowers' => 'as:manuallyApprovesFollowers' },
    sensitive: { 'sensitive' => 'as:sensitive' },
    hashtag: { 'Hashtag' => 'as:Hashtag' },
    moved_to: { 'movedTo' => { '@id' => 'as:movedTo', '@type' => '@id' } },
    also_known_as: { 'alsoKnownAs' => { '@id' => 'as:alsoKnownAs', '@type' => '@id' } },
    emoji: { 'toot' => 'http://joinmastodon.org/ns#', 'Emoji' => 'toot:Emoji' },
    featured: { 'toot' => 'http://joinmastodon.org/ns#', 'featured' => { '@id' => 'toot:featured', '@type' => '@id' }, 'featuredTags' => { '@id' => 'toot:featuredTags', '@type' => '@id' } },
    property_value: { 'schema' => 'http://schema.org#', 'PropertyValue' => 'schema:PropertyValue', 'value' => 'schema:value' },
    atom_uri: { 'ostatus' => 'http://ostatus.org#', 'atomUri' => 'ostatus:atomUri' },
    conversation: { 'ostatus' => 'http://ostatus.org#', 'inReplyToAtomUri' => 'ostatus:inReplyToAtomUri', 'conversation' => 'ostatus:conversation' },
    focal_point: { 'toot' => 'http://joinmastodon.org/ns#', 'focalPoint' => { '@container' => '@list', '@id' => 'toot:focalPoint' } },
    blurhash: { 'toot' => 'http://joinmastodon.org/ns#', 'blurhash' => 'toot:blurhash' },
    discoverable: { 'toot' => 'http://joinmastodon.org/ns#', 'discoverable' => 'toot:discoverable' },
    indexable: { 'toot' => 'http://joinmastodon.org/ns#', 'indexable' => 'toot:indexable' },
    memorial: { 'toot' => 'http://joinmastodon.org/ns#', 'memorial' => 'toot:memorial' },
    voters_count: { 'toot' => 'http://joinmastodon.org/ns#', 'votersCount' => 'toot:votersCount' },
    suspended: { 'toot' => 'http://joinmastodon.org/ns#', 'suspended' => 'toot:suspended' },
    attribution_domains: { 'toot' => 'http://joinmastodon.org/ns#', 'attributionDomains' => { '@id' => 'toot:attributionDomains', '@type' => '@id' } },
    quote_requests: { 'QuoteRequest' => 'https://w3id.org/fep/044f#QuoteRequest' },
    quotes: {
      'quote' => 'https://w3id.org/fep/044f#quote',
      'quoteUri' => 'http://fedibird.com/ns#quoteUri',
      '_misskey_quote' => 'https://misskey-hub.net/ns#_misskey_quote',
      'quoteAuthorization' => { '@id' => 'https://w3id.org/fep/044f#quoteAuthorization', '@type' => '@id' },
    },
    interaction_policies: {
      'gts' => 'https://gotosocial.org/ns#',
      'interactionPolicy' => { '@id' => 'gts:interactionPolicy', '@type' => '@id' },
      'canQuote' => { '@id' => 'gts:canQuote', '@type' => '@id' },
      'automaticApproval' => { '@id' => 'gts:automaticApproval', '@type' => '@id' },
      'manualApproval' => { '@id' => 'gts:manualApproval', '@type' => '@id' },
    },
    quote_authorizations: {
      'gts' => 'https://gotosocial.org/ns#',
      'quoteAuthorization' => { '@id' => 'https://w3id.org/fep/044f#quoteAuthorization', '@type' => '@id' },
      'interactingObject' => { '@id' => 'gts:interactingObject' },
      'interactionTarget' => { '@id' => 'gts:interactionTarget' },
    },
  }.freeze

  def full_context
    serialized_context(NAMED_CONTEXT_MAP, CONTEXT_EXTENSION_MAP)
  end

  def serialized_context(named_contexts_map, context_extensions_map)
    named_contexts     = named_contexts_map.keys
    context_extensions = context_extensions_map.keys

    context_array = named_contexts.map do |key|
      NAMED_CONTEXT_MAP[key]
    end

    extensions = context_extensions.each_with_object({}) do |key, h|
      h.merge!(CONTEXT_EXTENSION_MAP[key])
    end

    context_array << extensions unless extensions.empty?

    if context_array.size == 1
      context_array.first
    else
      context_array
    end
  end
end
