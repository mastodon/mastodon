# frozen_string_literal: true

class CustomEmojiFilter
  KEYS = %i(
    local
    remote
    by_domain
    shortcode
  ).freeze

  attr_reader :params

  def initialize(params)
    @params = params
  end

  def results
    scope = CustomEmoji.alphabetic

    params.each do |key, value|
      next if key.to_s == 'page'

      scope.merge!(scope_for(key, value)) if value.present?
    end

    scope
  end

  private

  def scope_for(key, value)
    case key.to_s
    when 'local'
      CustomEmoji.local.left_joins(:category).reorder(CustomEmojiCategory.arel_table[:name].asc.nulls_first).order(shortcode: :asc)
    when 'remote'
      CustomEmoji.remote
    when 'by_domain'
      CustomEmoji.where(domain: value)
    when 'shortcode'
      CustomEmoji.search(value.strip)
    else
      raise Mastodon::InvalidParameterError, "Unknown filter: #{key}"
    end
  end
end
