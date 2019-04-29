# frozen_string_literal: true

class StatusPinValidator < ActiveModel::Validator
  MAX_PINNED = (ENV['MAX_PINNED_TOOTS'] || 5).to_i
  
  def validate(pin)
    pin.errors.add(:base, I18n.t('statuses.pin_errors.reblog')) if pin.status.reblog?
    pin.errors.add(:base, I18n.t('statuses.pin_errors.ownership')) if pin.account_id != pin.status.account_id
    pin.errors.add(:base, I18n.t('statuses.pin_errors.private')) unless %w(public unlisted).include?(pin.status.visibility)
    pin.errors.add(:base, I18n.t('statuses.pin_errors.limit')) if pin.account.status_pins.count >= MAX_PINNED  && pin.account.local?
  end
end
