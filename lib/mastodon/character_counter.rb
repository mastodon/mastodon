# frozen_string_literal: true

class Mastodon::CharacterCounter
  URL_PLACEHOLDER = 'x' * 23

  def countable_note_text(value)
    return '' if value.nil?

    entities = Extractor.extract_urls_with_indices(value).sort_by { |e| e[:indices].first }

    result = rewrite_entities(value, entities) do |entity|
      URL_PLACEHOLDER if entity[:url]
    end

    result.gsub!(Account::MENTION_RE, '@\2')
    result
  end

  def countable_status_text(str)
    return '' if str.blank?

    # To ensure that we only give length concessions to entities that
    # will be correctly parsed during formatting, we go through full
    # entity extraction
    entities = Extractor.remove_overlapping_entities(Extractor.extract_urls_with_indices(str, extract_url_without_protocol: false) + Extractor.extract_mentions_or_lists_with_indices(str))

    rewrite_entities(str, entities) do |entity|
      if entity[:url]
        URL_PLACEHOLDER
      elsif entity[:screen_name]
        "@#{entity[:screen_name].split('@').first}"
      end
    end
  end

  private

  def rewrite_entities(str, entities)
    entities.sort_by! { |entity| entity[:indices].first }
    result = +''

    last_index = entities.reduce(0) do |index, entity|
      result << str[index...entity[:indices].first]
      result << yield(entity)
      entity[:indices].last
    end

    result << str[last_index..]
    result
  end
end
