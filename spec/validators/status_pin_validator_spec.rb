# frozen_string_literal: true

require 'rails_helper'

RSpec.describe StatusPinValidator, type: :validator do
  describe '#validate' do
    before do
      subject.validate(pin)
    end

    let(:pin) { double(account: account, errors: errors, status: status, account_id: pin_account_id) }
    let(:status) { double(reblog?: reblog, account_id: status_account_id, visibility: visibility) }
    let(:account)     { double(status_pins: status_pins, local?: local) }
    let(:status_pins) { double(count: count) }
    let(:errors)      { double(add: nil) }
    let(:pin_account_id)    { 1 }
    let(:status_account_id) { 1 }
    let(:visibility)  { 'public' }
    let(:local)       { false }
    let(:reblog)      { false }
    let(:count)       { 0 }

    context 'pin.status.reblog?' do
      let(:reblog) { true }

      it 'calls errors.add' do
        expect(errors).to have_received(:add).with(:base, I18n.t('statuses.pin_errors.reblog'))
      end
    end

    context 'pin.account_id != pin.status.account_id' do
      let(:pin_account_id)    { 1 }
      let(:status_account_id) { 2 }

      it 'calls errors.add' do
        expect(errors).to have_received(:add).with(:base, I18n.t('statuses.pin_errors.ownership'))
      end
    end

    context 'unless %w(public unlisted).include?(pin.status.visibility)' do
      let(:visibility) { '' }

      it 'calls errors.add' do
        expect(errors).to have_received(:add).with(:base, I18n.t('statuses.pin_errors.private'))
      end
    end

    context 'pin.account.status_pins.count > 4 && pin.account.local?' do
      let(:count) { 5 }
      let(:local) { true }

      it 'calls errors.add' do
        expect(errors).to have_received(:add).with(:base, I18n.t('statuses.pin_errors.limit'))
      end
    end
  end
end
