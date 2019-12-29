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
          ((?:https?|dat|dweb|ipfs|ipns|ssb|gopher):\/\/)?                                  #   $4 Protocol (optional)
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
    REGEXEN[:valid_xmpp_uri] = %r{
      (                                                                                     #   $1 total match
        (#{REGEXEN[:valid_url_preceding_chars]})                                            #   $2 Preceding character
        (                                                                                   #   $3 URL
          ((?:xmpp):)                                                                       #   $4 Protocol
          (//#{REGEXEN[:validate_nodeid]}+@#{REGEXEN[:valid_domain]}/)?                     #   $5 Authority (optional)
          (#{REGEXEN[:validate_nodeid]}+@)?                                                 #   $6 Username in path (optional)
          (#{REGEXEN[:valid_domain]})                                                       #   $7 Domain in path
          (/#{REGEXEN[:validate_resid]}+)?                                                  #   $8 Resource in path (optional)
          (\?#{REGEXEN[:valid_url_query_chars]}*#{REGEXEN[:valid_url_query_ending_chars]})? #   $9 Query String
        )
      )
    }iox
  end

  module Extractor
    # Extracts a list of all XMPP URIs included in the Tweet <tt>text</tt> along
    # with the indices. If the <tt>text</tt> is <tt>nil</tt> or contains no
    # XMPP URIs an empty array will be returned.
    #
    # If a block is given then it will be called for each XMPP URI.
    def extract_xmpp_uris_with_indices(text, options = {}) # :yields: uri, start, end
      return [] unless text && text.index(":")
      urls = []

      text.to_s.scan(Twitter::Regex[:valid_xmpp_uri]) do
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
