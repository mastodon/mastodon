# frozen_string_literal: true

class LinesValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if value.blank?

    record.errors.add(attribute, :too_many_lines, limit: options[:maximum]) if options[:maximum].present? && value.split.size > options[:maximum]
  end
end
