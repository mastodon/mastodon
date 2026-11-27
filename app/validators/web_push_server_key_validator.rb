# frozen_string_literal: true

class WebPushServerKeyValidator < ActiveModel::Validator
  def validate(subscription)
    subscription.errors.add(:base, I18n.t('webpush.errors.unknown_server_key')) if subscription.server_key.nil? || Rails.configuration.x.vapid.lookup(subscription.server_key).nil?
  end
end
