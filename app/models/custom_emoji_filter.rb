# frozen_string_literal: true

class CustomEmojiFilter
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
      CustomEmoji.local.left_joins(:category).reorder(Arel.sql('custom_emoji_categories.name ASC NULLS FIRST, custom_emojis.shortcode ASC'))
    when 'remote'
      CustomEmoji.remote
    when 'by_domain'
      CustomEmoji.where(domain: value.strip.downcase)
    when 'shortcode'
      CustomEmoji.search(value.strip)
    else
      raise "Unknown filter: #{key}"
    end
  end
end
