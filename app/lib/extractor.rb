# frozen_string_literal: true

# Adopted rb/lib/twitter-text/extractor.rb from twitter-text.
# Please contribute new changes of this file to the upstream if they are not specific to Mastodon.

# A module for including Toot parsing in a class. This module provides function for the extraction and processing
# of usernames, lists, URLs and hashtags.
module Extractor
  module_function

  # Remove overlapping entities.
  # This returns a new array with no overlapping entities.
  def remove_overlapping_entities(entities)
    # sort by start index
    entities = entities.sort_by { |entity| entity[:indices].first }

    # remove duplicates
    prev = nil
    entities.reject! { |entity| (prev && prev[:indices].last > entity[:indices].first) || (prev = entity) && false }
    entities
  end

  # Extracts all usernames, lists, hashtags and URLs  in the Toot <tt>text</tt>
  # along with the indices for where the entity ocurred
  # If the <tt>text</tt> is <tt>nil</tt> or contains no entity an empty array
  # will be returned.
  #
  # If a block is given then it will be called for each entity.
  def extract_entities_with_indices(text, options = {}, &block)
    # extract all entities
    entities = extract_urls_with_indices(text, options) +
               extract_hashtags_with_indices(text, check_url_overlap: false) +
               extract_mentions_with_indices(text)

    return [] if entities.empty?

    entities = remove_overlapping_entities(entities)

    entities.each(&block) if block_given?
    entities
  end

  # Extracts a list of all usernames mentioned in the Toot <tt>text</tt>. If the
  # <tt>text</tt> is <tt>nil</tt> or contains no username mentions an empty array
  # will be returned.
  #
  # If a block is given then it will be called for each username.
  def extract_mentions(text, &block) # :yields: username
    screen_names = extract_mentions_with_indices(text).map { |m| m[:screen_name] }
    screen_names.each(&block) if block_given?
    screen_names
  end

  # Extracts a list of all usernames or mentioned in the Toot <tt>text</tt>
  # along with the indices for where the mention ocurred.  If the
  # <tt>text</tt> is nil or contains no username mentions, an empty array
  # will be returned.
  #
  # If a block is given, then it will be called with each username, the start
  # index, and the end index in the <tt>text</tt>.
  def extract_mentions_with_indices(text) # :yields: username, start, end
    return [] unless text =~ Regex[:at_signs]

    possible_entries = []

    text.to_s.scan(Regex[:valid_mention]) do |screen_name, _|
      match_data = $LAST_MATCH_INFO
      after = $'
      unless after =~ Regex[:end_mention_match]
        start_position = match_data.begin(1) - 1
        end_position = match_data.end(1)
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

  # Extracts a list of all URLs included in the Tweet <tt>text</tt>. If the
  # <tt>text</tt> is <tt>nil</tt> or contains no URLs an empty array
  # will be returned.
  #
  # If a block is given then it will be called for each URL.
  def extract_urls(text, &block) # :yields: url
    urls = extract_urls_with_indices(text).map { |u| u[:url] }
    urls.each(&block) if block_given?
    urls
  end

  # Extracts a list of all URLs included in the Toot <tt>text</tt> along
  # with the indices. If the <tt>text</tt> is <tt>nil</tt> or contains no
  # URLs an empty array will be returned.
  #
  # If a block is given then it will be called for each URL.
  def extract_urls_with_indices(text, options = { extract_url_without_protocol: true }) # :yields: url, start, end
    return [] unless text && (options[:extract_url_without_protocol] ? text.index('.') : text.index(':'))
    urls = []

    text.to_s.scan(Regex[:valid_url]) do |_, before, url, protocol, domain, _, path, _| # rubocop:disable Metrics/ParameterLists
      valid_url_match_data = $LAST_MATCH_INFO

      start_position = valid_url_match_data.begin(3)
      end_position = valid_url_match_data.end(3)

      # If protocol is missing and domain contains non-ASCII characters,
      # extract ASCII-only domains.
      if !protocol
        next if !options[:extract_url_without_protocol] || before =~ Regex[:invalid_url_without_protocol_preceding_chars]
        last_url = nil
        domain.scan(Regex[:valid_ascii_domain]) do |ascii_domain|
          last_url = {
            url: ascii_domain,
            indices: [start_position + $LAST_MATCH_INFO.begin(0),
                      start_position + $LAST_MATCH_INFO.end(0)],
          }
          if path ||
             ascii_domain =~ Regex[:valid_special_short_domain] ||
             ascii_domain !~ Regex[:invalid_short_domain]
            urls << last_url
          end
        end

        # no ASCII-only domain found. Skip the entire URL
        next unless last_url

        # last_url only contains domain. Need to add path and query if they exist.
        if path
          # last_url was not added. Add it to urls here.
          last_url[:url] = url.sub(domain, last_url[:url])
          last_url[:indices][1] = end_position
        end
      else
        urls << {
          url: url,
          indices: [start_position, end_position],
        }
      end
    end
    urls.each { |url| yield url[:url], url[:indices].first, url[:indices].last } if block_given?
    urls
  end

  # Extracts a list of all hashtags included in the Tweet <tt>text</tt>. If the
  # <tt>text</tt> is <tt>nil</tt> or contains no hashtags an empty array
  # will be returned. The array returned will not include the leading <tt>#</tt>
  # character.
  #
  # If a block is given then it will be called for each hashtag.
  def extract_hashtags(text, &block) # :yields: hashtag_text
    hashtags = extract_hashtags_with_indices(text).map { |h| h[:hashtag] }
    hashtags.each(&block) if block_given?
    hashtags
  end

  # Extracts a list of all hashtags included in the Toot <tt>text</tt>. If the
  # <tt>text</tt> is <tt>nil</tt> or contains no hashtags an empty array
  # will be returned. The array returned will not include the leading <tt>#</tt>
  # character.
  #
  # If a block is given then it will be called for each hashtag.
  def extract_hashtags_with_indices(text, _options = {})
    return [] unless text =~ /#/

    tags = []
    text.scan(Regex[:valid_hashtag]) do |hash_text, _|
      match_data = $LAST_MATCH_INFO
      start_position = match_data.begin(1) - 1
      end_position = match_data.end(1)
      after = $'
      if after =~ Regex[:end_hashtag_match]
        hash_text.match(/(.+)(https?\Z)/) do |matched|
          hash_text = matched[1]
          end_position -= matched[2].length
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
end
