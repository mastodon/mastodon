# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Webhook do
  let(:webhook) { Fabricate(:webhook) }

  describe 'Validations' do
    it { is_expected.to validate_presence_of(:events) }

    it 'requires non-empty events value' do
      record = described_class.new(events: [])
      record.valid?

      expect(record).to model_have_error_on_field(:events)
    end

    it 'requires valid events value from EVENTS' do
      record = described_class.new(events: ['account.invalid'])
      record.valid?

      expect(record).to model_have_error_on_field(:events)
    end
  end

  describe 'Normalizations' do
    it 'cleans up events values' do
      record = described_class.new(events: ['account.approved', 'account.created     ', ''])

      expect(record.events).to eq(%w(account.approved account.created))
    end
  end

  describe '#rotate_secret!' do
    it 'changes the secret' do
      previous_value = webhook.secret
      webhook.rotate_secret!
      expect(webhook.secret).to_not be_blank
      expect(webhook.secret).to_not eq previous_value
    end
  end

  describe '#enable!' do
    before do
      webhook.disable!
    end

    it 'enables the webhook' do
      webhook.enable!
      expect(webhook.enabled?).to be true
    end
  end

  describe '#disable!' do
    it 'disables the webhook' do
      webhook.disable!
      expect(webhook.enabled?).to be false
    end
  end
end
