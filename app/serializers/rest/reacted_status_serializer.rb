# frozen_string_literal: true

class REST::ReactedStatusSerializer < REST::StatusSerializer
  def content
    original_content = super
    return original_content if !object.local? || object.emoji_count.empty?

    parsed_original_content = Nokogiri::HTML::DocumentFragment.parse(original_content)
    Nokogiri::HTML::Builder.with(parsed_original_content) do |doc|
      doc.p do
        object.emoji_count.each do |emoji, count|
          doc.span do
            doc.span("#{emoji} (#{count})")
          end
        end
      end
    end
    parsed_original_content.to_html
  end
end
