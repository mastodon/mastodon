# frozen_string_literal: true

# NOTE: I initially wrote this as `EmailValidator` but it ended up clashing
# with an indirect dependency of ours, `validate_email`, which, turns out,
# has the same approach as we do, but with an extra check disallowing
# single-label domains. Decided to not switch to `validate_email` because
# we do want to allow at least `localhost`.

class EmailAddressValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    value = value.strip

    address = Mail::Address.new(value)
    record.errors.add(attribute, :invalid) if address.address != value
  rescue Mail::Field::FieldError
    record.errors.add(attribute, :invalid)
  end
end
