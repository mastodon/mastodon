# frozen_string_literal: true

module Extractor
  extend Twitter::Extractor

  module_function

  # Extracts all usernames, lists, hashtags and URLs  in the Tweet <tt>text</tt>
  # along with the indices for where the entity ocurred
  # If the <tt>text</tt> is <tt>nil</tt> or contains no entity an empty array
  # will be returned.
  #
  # If a block is given then it will be called for each entity.
  def extract_entities_with_indices(text, options = {}, &block)
    # extract all entities
    entities = extract_urls_with_indices(text, options) +
               extract_hashtags_with_indices(text, check_url_overlap: false) +
               extract_mentions_or_lists_with_indices(text) +
               extract_shortcodes_with_indices(text)

    return [] if entities.empty?

    entities = remove_overlapping_entities(entities)

    entities.each(&block) if block_given?
    entities
  end

  # :yields: username, list_slug, start, end
  def extract_mentions_or_lists_with_indices(text)
    return [] unless text =~ Twitter::Regex[:at_signs]

    possible_entries = []

    text.to_s.scan(Account::MENTION_RE) do |screen_name, _|
      match_data = $LAST_MATCH_INFO
      after = $'
      unless after =~ Twitter::Regex[:end_mention_match]
        start_position = match_data.char_begin(1) - 1
        end_position = match_data.char_end(1)
        possible_entries << {
          screen_name: screen_name,
          indices: [start_position, end_position],
        }
      end
    end

    if block_given?
      possible_entries.each do |mention|
        yield mention[:screen_name], mention[:indices].first, mention[:indices].last
      end
    end
    possible_entries
  end

  def extract_hashtags_with_indices(text, _options = {})
    return [] unless text =~ /#/

    tags = []
    text.scan(Tag::HASHTAG_RE) do |hash_text, _|
      match_data = $LAST_MATCH_INFO
      start_position = match_data.char_begin(1) - 1
      end_position = match_data.char_end(1)
      after = $'
      if after =~ %r{\A://}
        hash_text.match(/(.+)(https?\Z)/) do |matched|
          hash_text = matched[1]
          end_position -= matched[2].char_length
        end
      end

      tags << {
        hashtag: hash_text,
        indices: [start_position, end_position],
      }
    end

    tags.each { |tag| yield tag[:hashtag], tag[:indices].first, tag[:indices].last } if block_given?
    tags
  end

  def extract_shortcodes_with_indices(text, html: false)
    return [] unless text =~ /:/

    emojis = []

    text.to_s.scan(html ? CustomEmoji::HTML_SCAN_RE : CustomEmoji::RAW_SCAN_RE) do |shortcode, _|
      match_data = $LAST_MATCH_INFO
      start_position = match_data.char_begin(1) - 1
      end_position = match_data.char_end(1) + 1
      emojis << {
        shortcode: shortcode,
        indices: [start_position, end_position],
      }
    end

    emojis.each { |emoji| yield emoji[:shortcode], emoji[:indices].first, emoji[:indices].last } if block_given?
    emojis
  end
end
