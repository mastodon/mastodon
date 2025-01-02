# frozen_string_literal: true

class EmptyProfileFieldNamesValidator < ActiveModel::Validator
  def validate(account)
    return if account.fields.empty?

    account.errors.add(:fields, 'Names of profile fields cannot be empty') if fields_with_values_missing_names?(account)
  end

  private

  def fields_with_values_missing_names?(account)
    account.fields.each do |field|
      return true if field.name.blank? && field.value.present?
    end
    return false
  end
end
