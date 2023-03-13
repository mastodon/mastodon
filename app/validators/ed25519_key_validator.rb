# frozen_string_literal: true

class Ed25519KeyValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if value.blank?

    key = Base64.decode64(value)

    record.errors.add(attribute, I18n.t('crypto.errors.invalid_key')) unless verified?(key)
  end

  private

  def verified?(key)
    Ed25519.validate_key_bytes(key)
  rescue ArgumentError
    false
  end
end
