# frozen_string_literal: true

class DateOfBirthValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    record.errors.add(attribute, :below_limit) if value.present? && value.to_date > min_age.ago
  end

  private

  def min_age
    Setting.min_age.to_i.years
  end
end
