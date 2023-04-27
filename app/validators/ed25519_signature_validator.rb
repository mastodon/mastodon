# frozen_string_literal: true

class Ed25519SignatureValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if value.blank?

    verify_key = Ed25519::VerifyKey.new(Base64.decode64(option_to_value(record, :verify_key)))
    signature  = Base64.decode64(value)
    message    = option_to_value(record, :message)

    record.errors.add(attribute, I18n.t('crypto.errors.invalid_signature')) unless verified?(verify_key, signature, message)
  end

  private

  def verified?(verify_key, signature, message)
    verify_key.verify(signature, message)
  rescue Ed25519::VerifyError, ArgumentError
    false
  end

  def option_to_value(record, key)
    if options[key].is_a?(Proc)
      options[key].call(record)
    else
      record.public_send(options[key])
    end
  end
end
