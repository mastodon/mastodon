# frozen_string_literal: true

class ActivityPub::Parser::StatusParser
  include JsonLdHelper

  # @param [Hash] json
  # @param [Hash] magic_values
  # @option magic_values [String] :followers_collection
  def initialize(json, magic_values = {})
    @json         = json
    @object       = json['object'] || json
    @magic_values = magic_values
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
    @object['published']&.to_datetime
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
    elsif audience_to.include?(@magic_values[:followers_collection])
      :private
    elsif direct_message == false
      :limited
    else
      :direct
    end
  end

  def language
    if content_language_map?
      @object['contentMap'].keys.first
    elsif name_language_map?
      @object['nameMap'].keys.first
    elsif summary_language_map?
      @object['summaryMap'].keys.first
    end
  end

  def direct_message
    @object['directMessage']
  end

  private

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
