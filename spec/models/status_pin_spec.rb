# frozen_string_literal: true

require 'rails_helper'

RSpec.describe StatusPin do
  describe 'validations' do
    it 'allows pins of own statuses' do
      account = Fabricate(:account)
      status  = Fabricate(:status, account: account)

      expect(described_class.new(account: account, status: status).save).to be true
    end

    it 'does not allow pins of statuses by someone else' do
      account = Fabricate(:account)
      status  = Fabricate(:status)

      expect(described_class.new(account: account, status: status).save).to be false
    end

    it 'does not allow pins of reblogs' do
      account = Fabricate(:account)
      status  = Fabricate(:status, account: account)
      reblog  = Fabricate(:status, reblog: status)

      expect(described_class.new(account: account, status: reblog).save).to be false
    end

    it 'does allow pins of direct statuses' do
      account = Fabricate(:account)
      status  = Fabricate(:status, account: account, visibility: :private)

      expect(described_class.new(account: account, status: status).save).to be true
    end

    it 'does not allow pins of direct statuses' do
      account = Fabricate(:account)
      status  = Fabricate(:status, account: account, visibility: :direct)

      expect(described_class.new(account: account, status: status).save).to be false
    end

    context 'with a pin limit' do
      before { stub_const('StatusPinValidator::PIN_LIMIT', 2) }

      it 'does not allow pins above the max' do
        account = Fabricate(:account)

        Fabricate.times(StatusPinValidator::PIN_LIMIT, :status_pin, account: account)

        pin = described_class.new(account: account, status: Fabricate(:status, account: account))
        expect(pin.save)
          .to be(false)

        expect(pin.errors[:base])
          .to contain_exactly(I18n.t('statuses.pin_errors.limit'))
      end

      it 'allows pins above the max for remote accounts' do
        account = Fabricate(:account, domain: 'remote.test', username: 'bob', url: 'https://remote.test/')

        Fabricate.times(StatusPinValidator::PIN_LIMIT, :status_pin, account: account)

        pin = described_class.new(account: account, status: Fabricate(:status, account: account))
        expect(pin.save)
          .to be(true)

        expect(pin.errors[:base])
          .to be_empty
      end
    end
  end
end
