# == Schema Information
#
# Table name: custom_templates
#
#  id         :bigint(8)        not null, primary key
#  content    :text             not null
#  disabled   :boolean          default(FALSE), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class CustomTemplate < ApplicationRecord
  scope :alphabetic, -> { order(content: :asc) }

  def emojis
    CustomEmoji.from_text(content, nil)
  end

  def preview
    emojis = self.emojis
    position = 0
    codes = []

    while (m = content.match(CustomEmoji::SCAN_RE, position))
      codes << content[position..m.begin(0) - 1] if m.begin(0) > 0

      emoji = emojis.find { |e| e.shortcode == m[1] }
      if emoji
        codes << emoji
      else
        codes << content[m.begin(0)..m.end(0)]
      end

      position = m.end(0)
    end

    codes << content[position..-1]
    codes
  end
end
