# frozen_string_literal: true

class Hashtag
  SEPARATORS = "_\u00B7\u30FB\u200c"
  FIRST_SEQUENCE_CHUNK_ONE = "[[:word:]_][[:word:]#{SEPARATORS}]*[[:alpha:]#{SEPARATORS}]".freeze
  FIRST_SEQUENCE_CHUNK_TWO = "[[:word:]#{SEPARATORS}]*[[:word:]_]".freeze
  FIRST_SEQUENCE = "(#{FIRST_SEQUENCE_CHUNK_ONE}#{FIRST_SEQUENCE_CHUNK_TWO})".freeze
  LAST_SEQUENCE = '([[:word:]_]*[[:alpha:]][[:word:]_]*)'
  NAME_PAT = "#{FIRST_SEQUENCE}|#{LAST_SEQUENCE}".freeze

  EXTRACTION_RE = /(?<=^|[[:space:]])[#＃](#{NAME_PAT})/
  NAME_RE = /\A(#{NAME_PAT})\z/i

  INVALID_CHARS_RE = /[^[:alnum:]\u0E47-\u0E4E#{SEPARATORS}]/

  private_constant :FIRST_SEQUENCE_CHUNK_ONE, :FIRST_SEQUENCE_CHUNK_TWO, :FIRST_SEQUENCE, :LAST_SEQUENCE, :NAME_PAT

  class << self
    def normalize(str)
      unicode_normalize(str)
        .then { |value| lowercase(value) }
        .then { |value| ascii_fold(value) }
        .then { |value| remove_invalid_characters(value) }
    end

    private

    def unicode_normalize(str)
      str.unicode_normalize(:nfkc)
    end

    def lowercase(str)
      str.downcase.to_s
    end

    def ascii_fold(str)
      ASCIIFolding.new.fold(str)
    end

    def remove_invalid_characters(str)
      str.gsub(INVALID_CHARS_RE, '')
    end
  end
end
