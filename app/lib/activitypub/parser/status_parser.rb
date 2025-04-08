# frozen_string_literal: true

class ActivityPub::Parser::StatusParser
  include JsonLdHelper

  NORMALIZED_LOCALE_NAMES = LanguagesHelper::SUPPORTED_LOCALES.keys.index_by(&:downcase).freeze

  # @param [Hash] json
  # @param [Hash] options
  # @option options [String] :followers_collection
  # @option options [String] :actor_uri
  # @option options [Hash]   :object
  def initialize(json, **options)
    @json    = json
    @object  = options[:object] || json['object'] || json
    @options = options
  end

  def uri
    id = @object['id']

    if id&.start_with?('bear:')
      Addressable::URI.parse(id).query_values['u']
    else
      id
    end
  rescue Addressable::URI::InvalidURIError
    id
  end

  def url
    url_to_href(@object['url'], 'text/html') if @object['url'].present?
  end

  def text
    if @object['content'].present?
      @object['content']
    elsif content_language_map?
      @object['contentMap'].values.first
    end
  end

  def spoiler_text
    if @object['summary'].present?
      @object['summary']
    elsif summary_language_map?
      @object['summaryMap'].values.first
    end
  end

  def title
    if @object['name'].present?
      @object['name']
    elsif name_language_map?
      @object['nameMap'].values.first
    end
  end

  def created_at
    datetime = @object['published']&.to_datetime
    datetime if datetime.present? && (0..9999).cover?(datetime.year)
  rescue ArgumentError
    nil
  end

  def edited_at
    @object['updated']&.to_datetime
  rescue ArgumentError
    nil
  end

  def reply
    @object['inReplyTo'].present?
  end

  def sensitive
    @object['sensitive']
  end

  def visibility
    if audience_to.any? { |to| ActivityPub::TagManager.instance.public_collection?(to) }
      :public
    elsif audience_cc.any? { |cc| ActivityPub::TagManager.instance.public_collection?(cc) }
      :unlisted
    elsif audience_to.include?(@options[:followers_collection])
      :private
    else
      :direct
    end
  end

  def language
    lang = raw_language_code
    lang.presence && NORMALIZED_LOCALE_NAMES.fetch(lang.downcase.to_sym, lang)
  end

  def favourites_count
    @object.dig(:likes, :totalItems)
  end

  def reblogs_count
    @object.dig(:shares, :totalItems)
  end

  def quote_policy
    flags = 0
    policy = @object.dig('interactionPolicy', 'canQuote')
    return flags if policy.blank?

    flags |= quote_subpolicy(policy['automaticApproval'])
    flags <<= 16
    flags |= quote_subpolicy(policy['manualApproval'])

    flags
  end

  def quote_uri
    %w(quote _misskey_quote quoteUrl quoteUri).filter_map do |key|
      value_or_id(as_array(@object[key]).first)
    end.first
  end

  def quote_approval_uri
    as_array(@object['quoteAuthorization']).first
  end

  private

  def quote_subpolicy(subpolicy)
    flags = 0

    allowed_actors = as_array(subpolicy)
    allowed_actors.uniq!

    flags |= Status::QUOTE_APPROVAL_POLICY_FLAGS[:public] if allowed_actors.delete('as:Public') || allowed_actors.delete('Public') || allowed_actors.delete('https://www.w3.org/ns/activitystreams#Public')
    flags |= Status::QUOTE_APPROVAL_POLICY_FLAGS[:followers] if allowed_actors.delete(@options[:followers_collection])
    # TODO: we don't actually store that collection URI
    # flags |= Status::QUOTE_APPROVAL_POLICY_FLAGS[:followed]

    # Remove the special-meaning actor URI
    allowed_actors.delete(@options[:actor_uri])

    # Tagged users are always allowed, so remove them
    allowed_actors -= as_array(@object['tag']).filter_map { |tag| tag['href'] if equals_or_includes?(tag['type'], 'Mention') }

    # Any unrecognized actor is marked as unknown
    flags |= Status::QUOTE_APPROVAL_POLICY_FLAGS[:unknown] unless allowed_actors.empty?

    flags
  end

  def raw_language_code
    if content_language_map?
      @object['contentMap'].keys.first
    elsif name_language_map?
      @object['nameMap'].keys.first
    elsif summary_language_map?
      @object['summaryMap'].keys.first
    end
  end

  def audience_to
    as_array(@object['to'] || @json['to']).map { |x| value_or_id(x) }
  end

  def audience_cc
    as_array(@object['cc'] || @json['cc']).map { |x| value_or_id(x) }
  end

  def summary_language_map?
    @object['summaryMap'].is_a?(Hash) && !@object['summaryMap'].empty?
  end

  def content_language_map?
    @object['contentMap'].is_a?(Hash) && !@object['contentMap'].empty?
  end

  def name_language_map?
    @object['nameMap'].is_a?(Hash) && !@object['nameMap'].empty?
  end
end
