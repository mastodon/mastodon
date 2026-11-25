# frozen_string_literal: true

class Hashtag
  class << self
    def normalize(str)
      unicode_normalize(str)
        .then { |value| lowercase(value) }
        .then { |value| ascii_fold(value) }
        .then { |value| remove_invalid_characters(value) }
    end

    private

    def remove_invalid_characters(str)
      str.gsub(Tag::HASHTAG_INVALID_CHARS_RE, '')
    end

    def ascii_fold(str)
      ASCIIFolding.new.fold(str)
    end

    def lowercase(str)
      str.downcase.to_s
    end

    def unicode_normalize(str)
      str.unicode_normalize(:nfkc)
    end
  end
end
