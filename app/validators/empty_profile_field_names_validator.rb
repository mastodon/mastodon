# frozen_string_literal: true

class EmptyProfileFieldNamesValidator < ActiveModel::Validator
  def validate(account)
    return if account.fields.empty?

    field_names_valid = true
    account.fields.each do |field|
      field_names_valid = false if field.name.blank? && field.value.present?
    end
    return if field_names_valid

    account.errors.add(:fields, 'Names of profile fields cannot be empty')
  end
end