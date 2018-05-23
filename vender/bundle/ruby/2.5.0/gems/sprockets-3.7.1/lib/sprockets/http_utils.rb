module Sprockets
  # Internal: HTTP URI utilities. Many adapted from Rack::Utils. Mixed into
  # Environment.
  module HTTPUtils
    extend self

    # Public: Test mime type against mime range.
    #
    #    match_mime_type?('text/html', 'text/*') => true
    #    match_mime_type?('text/plain', '*') => true
    #    match_mime_type?('text/html', 'application/json') => false
    #
    # Returns true if the given value is a mime match for the given mime match
    # specification, false otherwise.
    def match_mime_type?(value, matcher)
      v1, v2 = value.split('/', 2)
      m1, m2 = matcher.split('/', 2)
      (m1 == '*' || v1 == m1) && (m2.nil? || m2 == '*' || m2 == v2)
    end

    # Public: Return values from Hash where the key matches the mime type.
    #
    # hash      - Hash of String matcher keys to Object values
    # mime_type - String mime type
    #
    # Returns Array of Object values.
    def match_mime_type_keys(hash, mime_type)
      type, subtype = mime_type.split('/', 2)
      [
        hash["*"],
        hash["*/*"],
        hash["#{type}/*"],
        hash["#{type}/#{subtype}"]
      ].compact
    end

    # Internal: Parse Accept header quality values.
    #
    # Adapted from Rack::Utils#q_values.
    #
    # Returns an Array of [String, Float].
    def parse_q_values(values)
      values.to_s.split(/\s*,\s*/).map do |part|
        value, parameters = part.split(/\s*;\s*/, 2)
        quality = 1.0
        if md = /\Aq=([\d.]+)/.match(parameters)
          quality = md[1].to_f
        end
        [value, quality]
      end
    end

    # Internal: Find all qvalue matches from an Array of available options.
    #
    # Adapted from Rack::Utils#q_values.
    #
    # Returns Array of matched Strings from available Array or [].
    def find_q_matches(q_values, available, &matcher)
      matcher ||= lambda { |a, b| a == b }

      matches = []

      case q_values
      when Array
      when String
        q_values = parse_q_values(q_values)
      when NilClass
        q_values = []
      else
        raise TypeError, "unknown q_values type: #{q_values.class}"
      end

      q_values.each do |accepted, quality|
        if match = available.find { |option| matcher.call(option, accepted) }
          matches << [match, quality]
        end
      end

      matches.sort_by! { |match, quality| -quality }
      matches.map! { |match, quality| match }
      matches
    end

    # Internal: Find the best qvalue match from an Array of available options.
    #
    # Adapted from Rack::Utils#q_values.
    #
    # Returns the matched String from available Array or nil.
    def find_best_q_match(q_values, available, &matcher)
      find_q_matches(q_values, available, &matcher).first
    end

    # Internal: Find the all qvalue match from an Array of available mime type
    # options.
    #
    # Adapted from Rack::Utils#q_values.
    #
    # Returns Array of matched mime type Strings from available Array or [].
    def find_mime_type_matches(q_value_header, available)
      find_q_matches(q_value_header, available) do |a, b|
        match_mime_type?(a, b)
      end
    end

    # Internal: Find the best qvalue match from an Array of available mime type
    # options.
    #
    # Adapted from Rack::Utils#q_values.
    #
    # Returns the matched mime type String from available Array or nil.
    def find_best_mime_type_match(q_value_header, available)
      find_best_q_match(q_value_header, available) do |a, b|
        match_mime_type?(a, b)
      end
    end
  end
end
