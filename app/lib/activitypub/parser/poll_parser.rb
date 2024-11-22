# frozen_string_literal: true

class ActivityPub::Parser::PollParser
  include JsonLdHelper

  def initialize(json)
    @json = json
  end

  def valid?
    equals_or_includes?(@json['type'], 'Question') && items.is_a?(Array)
  end

  # @param [Poll] previous_record
  def significantly_changes?(previous_record)
    options != previous_record.options ||
      multiple != previous_record.multiple
  end

  def options
    items.filter_map { |item| item['name'].presence || item['content'] }
  end

  def multiple
    @json['anyOf'].is_a?(Array)
  end

  def expires_at
    if @json['closed'].is_a?(String)
      @json['closed'].to_datetime
    elsif !@json['closed'].nil? && !@json['closed'].is_a?(FalseClass)
      Time.now.utc
    else
      @json['endTime']&.to_datetime
    end
  rescue ArgumentError
    nil
  end

  def voters_count
    @json['votersCount']
  end

  def cached_tallies
    items.map { |item| item.dig('replies', 'totalItems') || 0 }
  end

  private

  def items
    @json['anyOf'] || @json['oneOf']
  end
end
