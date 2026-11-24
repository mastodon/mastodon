# frozen_string_literal: true

class NoteLengthValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    record.errors.add(attribute, :too_long, count: options[:maximum]) if too_long?(value)
  end

  private

  def too_long?(value)
    countable_text(value).each_grapheme_cluster.size > options[:maximum]
  end

  def countable_text(value)
    return '' if value.nil?

    entities = Extractor.extract_urls_with_indices(value).sort_by { |e| e[:indices].first }
    result = +''
    last = entities.reduce(0) do |i, entity|
      result << value[i...entity[:indices].first]
      result << StatusLengthValidator::URL_PLACEHOLDER
      entity[:indices].last
    end
    result << value[last..]
    result.gsub!(Account::MENTION_RE, '@\2')
    result
  end
end
