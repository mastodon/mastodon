module Twitter
  class Regex
    REGEXEN[:valid_general_url_path_chars] = /[^\p{White_Space}<>\(\)\?]/iou
    REGEXEN[:valid_url_path_ending_chars] = /[^\p{White_Space}\(\)\?!\*"'「」<>;:=\,\.\$%\[\]~&\|@]|(?:#{REGEXEN[:valid_url_balanced_parens]})/iou
    REGEXEN[:valid_url_balanced_parens] = /
      \(
        (?:
          #{REGEXEN[:valid_general_url_path_chars]}+
          |
          # allow one nested level of balanced parentheses
          (?:
            #{REGEXEN[:valid_general_url_path_chars]}*
            \(
              #{REGEXEN[:valid_general_url_path_chars]}+
            \)
            #{REGEXEN[:valid_general_url_path_chars]}*
          )
        )
      \)
    /iox
    REGEXEN[:valid_url_path] = /(?:
      (?:
        #{REGEXEN[:valid_general_url_path_chars]}*
        (?:#{REGEXEN[:valid_url_balanced_parens]} #{REGEXEN[:valid_general_url_path_chars]}*)*
        #{REGEXEN[:valid_url_path_ending_chars]}
      )|(?:#{REGEXEN[:valid_general_url_path_chars]}+\/)
    )/iox
    REGEXEN[:valid_url] = %r{
      (                                                                                     #   $1 total match
        (#{REGEXEN[:valid_url_preceding_chars]})                                            #   $2 Preceding character
        (                                                                                   #   $3 URL
          ((?:https?|dat|dweb|ipfs|ipns|ssb|gopher|gemini):\/\/)?                           #   $4 Protocol (optional)
          (#{REGEXEN[:valid_domain]})                                                       #   $5 Domain(s)
          (?::(#{REGEXEN[:valid_port_number]}))?                                            #   $6 Port number (optional)
          (/#{REGEXEN[:valid_url_path]}*)?                                                  #   $7 URL Path and anchor
          (\?#{REGEXEN[:valid_url_query_chars]}*#{REGEXEN[:valid_url_query_ending_chars]})? #   $8 Query String
        )
      )
    }iox
    REGEXEN[:validate_nodeid] = /(?:
      #{REGEXEN[:validate_url_unreserved]}|
      #{REGEXEN[:validate_url_pct_encoded]}|
      [!$()*+,;=]
    )/iox
    REGEXEN[:validate_resid] = /(?:
      #{REGEXEN[:validate_url_unreserved]}|
      #{REGEXEN[:validate_url_pct_encoded]}|
      #{REGEXEN[:validate_url_sub_delims]}
    )/iox
    REGEXEN[:xmpp_uri] = %r{
      (xmpp:)                                                                           # Protocol
      (//#{REGEXEN[:validate_nodeid]}+@#{REGEXEN[:valid_domain]}/)?                     # Authority (optional)
      (#{REGEXEN[:validate_nodeid]}+@)?                                                 # Username in path (optional)
      (#{REGEXEN[:valid_domain]})                                                       # Domain in path
      (/#{REGEXEN[:validate_resid]}+)?                                                  # Resource in path (optional)
      (\?#{REGEXEN[:valid_url_query_chars]}*#{REGEXEN[:valid_url_query_ending_chars]})? # Query String
    }iox
    REGEXEN[:magnet_uri] = %r{
      (magnet:)                                                                         # Protocol
      (\?#{REGEXEN[:valid_url_query_chars]}*#{REGEXEN[:valid_url_query_ending_chars]})  # Query String
    }iox
    REGEXEN[:valid_extended_uri] = %r{
      (                                                                                 #   $1 total match
        (#{REGEXEN[:valid_url_preceding_chars]})                                        #   $2 Preceding character
        (                                                                               #   $3 URL
          (#{REGEXEN[:xmpp_uri]}) | (#{REGEXEN[:magnet_uri]})
        )
      )
    }iox
  end

  module Extractor
    # Extracts a list of all XMPP and magnet URIs included in the Toot <tt>text</tt> along
    # with the indices. If the <tt>text</tt> is <tt>nil</tt> or contains no
    # XMPP or magnet URIs an empty array will be returned.
    #
    # If a block is given then it will be called for each XMPP URI.
    def extract_extra_uris_with_indices(text, options = {}) # :yields: uri, start, end
      return [] unless text && text.index(":")
      urls = []

      text.to_s.scan(Twitter::Regex[:valid_extended_uri]) do
        valid_uri_match_data = $~

        start_position = valid_uri_match_data.char_begin(3)
        end_position = valid_uri_match_data.char_end(3)

        urls << {
          :url => valid_uri_match_data[3],
          :indices => [start_position, end_position]
        }
      end
      urls.each{|url| yield url[:url], url[:indices].first, url[:indices].last} if block_given?
      urls
    end
  end
end
