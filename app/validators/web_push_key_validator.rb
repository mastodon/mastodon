# frozen_string_literal: true

class WebPushKeyValidator < ActiveModel::Validator
  def validate(subscription)
    begin
      Webpush::Encryption.encrypt('validation_test', subscription.key_p256dh, subscription.key_auth)
    rescue ArgumentError, OpenSSL::PKey::EC::Point::Error
      subscription.errors.add(:base, I18n.t('crypto.errors.invalid_key'))
    end
  end
end
