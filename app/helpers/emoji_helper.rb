# frozen_string_literal: true

module EmojiHelper
  def emojify(text)
    return text if text.blank?

    text.gsub(emoji_pattern) do |match|
      emoji = Emoji.instance.unicode($1) # rubocop:disable Style/PerlBackrefs

      if emoji
        emoji
      else
        match
      end
    end
  end

  def emoji_pattern
    @emoji_pattern ||=
      /(?<=[^[:alnum:]:]|\n|^)
      (#{Emoji.instance.names.map { |name| Regexp.escape(name) }.join('|')})
      (?=[^[:alnum:]:]|$)/x
  end
end
