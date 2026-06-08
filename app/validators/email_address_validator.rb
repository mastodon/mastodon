# frozen_string_literal: true

class EmailAddressValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    value = value.strip

    address = Mail::Address.new(value)
    record.errors.add(attribute, :invalid) if address.address != value || contains_disallowed_characters?(value)
  rescue Mail::Field::FieldError
    record.errors.add(attribute, :invalid)
  end

  private

  def contains_disallowed_characters?(value)
    value.include?('%') || value.include?(',') || value.include?('"')
  end
end
