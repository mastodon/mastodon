# frozen_string_literal: true

module EmojiHelper
  EMOJI_PATTERN = /(?<=[^[:alnum:]:]|\n|^):([\w+-]+):(?=[^[:alnum:]:]|$)/x

  def emojify(text)
    return text if text.blank?

    text.gsub(EMOJI_PATTERN) do |match|
      emoji = Emoji.find_by_alias($1) # rubocop:disable Rails/DynamicFindBy,Style/PerlBackrefs

      if emoji
        emoji.raw
      else
        match
      end
    end
  end
end
