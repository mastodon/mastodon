# frozen_string_literal: true

class HashtagNormalizer
  class << self
    def normalize(str)
      cjk_width(str)
        .then { |value| lowercase(value) }
        .then { |value| ascii_folding(value) }
        .then { |value| remove_invalid_characters(value) }
    end

    private

    def remove_invalid_characters(str)
      str.gsub(Tag::HASHTAG_INVALID_CHARS_RE, '')
    end

    def ascii_folding(str)
      ASCIIFolding.new.fold(str)
    end

    def lowercase(str)
      str.downcase.to_s
    end

    def cjk_width(str)
      str.unicode_normalize(:nfkc)
    end
  end
end
