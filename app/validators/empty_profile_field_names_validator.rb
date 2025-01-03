# frozen_string_literal: true

class EmptyProfileFieldNamesValidator < ActiveModel::Validator
  def validate(account)
    return if account.fields.empty?

    account.errors.add(:fields, :fields_with_values_missing_labels) if fields_with_values_missing_names?(account)
  end

  private

  def fields_with_values_missing_names?(account)
    account.fields.any? { |field| field.name.blank? && field.value.present? }
  end
end
