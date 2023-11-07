# frozen_string_literal: true

require 'rails_helper'

RSpec.describe StatusPinValidator, type: :validator do
  describe '#validate' do
    before do
      subject.validate(pin)
    end

    let(:pin) { instance_double(StatusPin, account: account, errors: errors, status: status, account_id: pin_account_id) }
    let(:status) { instance_double(Status, reblog?: reblog, account_id: status_account_id, visibility: visibility, direct_visibility?: visibility == 'direct') }
    let(:account)     { instance_double(Account, status_pins: status_pins, local?: local) }
    let(:status_pins) { instance_double(Array, count: count) }
    let(:errors)      { instance_double(ActiveModel::Errors, add: nil) }
    let(:pin_account_id)    { 1 }
    let(:status_account_id) { 1 }
    let(:visibility)  { 'public' }
    let(:local)       { false }
    let(:reblog)      { false }
    let(:count)       { 0 }

    context 'when pin.status.reblog?' do
      let(:reblog) { true }

      it 'calls errors.add' do
        expect(errors).to have_received(:add).with(:base, I18n.t('statuses.pin_errors.reblog'))
      end
    end

    context 'when pin.account_id != pin.status.account_id' do
      let(:pin_account_id)    { 1 }
      let(:status_account_id) { 2 }

      it 'calls errors.add' do
        expect(errors).to have_received(:add).with(:base, I18n.t('statuses.pin_errors.ownership'))
      end
    end

    context 'when pin.status.direct_visibility?' do
      let(:visibility) { 'direct' }

      it 'calls errors.add' do
        expect(errors).to have_received(:add).with(:base, I18n.t('statuses.pin_errors.direct'))
      end
    end

    context 'when pin.account.status_pins.count > 4 && pin.account.local?' do
      let(:count) { 5 }
      let(:local) { true }

      it 'calls errors.add' do
        expect(errors).to have_received(:add).with(:base, I18n.t('statuses.pin_errors.limit'))
      end
    end
  end
end
