# frozen_string_literal: true

class HashtagNormalizer
  def normalize(str)
    remove_invalid_characters(ascii_folding(lowercase(cjk_width(str))))
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
