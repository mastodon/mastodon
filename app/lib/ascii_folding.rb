# frozen_string_literal: true

class ASCIIFolding
  CONVERSIONS = I18n::Backend::Transliterator::HashTransliterator::DEFAULT_APPROXIMATIONS

  def fold(str)
    str.gsub(/[#{CONVERSIONS.keys.join}]/, CONVERSIONS)
  end
end
