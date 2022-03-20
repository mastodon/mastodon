# frozen_string_literal: true

module FormattingHelper
  def linkify(text, options = {})
    TextFormatter.new(text, options).to_s
  end
end
