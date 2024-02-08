# frozen_string_literal: true

class StatusPinValidator < ActiveModel::Validator
  PIN_LIMIT = 5

  def validate(pin)
    pin.errors.add(:base, I18n.t('statuses.pin_errors.reblog')) if pin.status.reblog?
    pin.errors.add(:base, I18n.t('statuses.pin_errors.ownership')) if pin.account_id != pin.status.account_id
    pin.errors.add(:base, I18n.t('statuses.pin_errors.direct')) if pin.status.direct_visibility?
    pin.errors.add(:base, I18n.t('statuses.pin_errors.limit')) if pin.account.status_pins.count >= PIN_LIMIT && pin.account.local?
  end
end
