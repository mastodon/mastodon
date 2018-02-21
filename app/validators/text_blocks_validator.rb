# frozen_string_literal: true

class TextBlocksValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if value.nil?

    rejected = TextBlock.rejected_texts.find { |text| value.include? text }
    record.errors.add attribute, I18n.t('rejected_text', text: rejected) if rejected.present?
  end
end
