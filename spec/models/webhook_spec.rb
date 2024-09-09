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
    describe 'events' do
      it { is_expected.to normalize(:events).from(['account.approved', 'account.created     ', '']).to(%w(account.approved account.created)) }
    end
  end

  describe '#rotate_secret!' do
    it 'changes the secret' do
      expect { webhook.rotate_secret! }
        .to change(webhook, :secret)
      expect(webhook.secret)
        .to_not be_blank
    end
  end

  describe '#enable!' do
    let(:webhook) { Fabricate(:webhook, enabled: false) }

    it 'enables the webhook' do
      expect { webhook.enable! }
        .to change(webhook, :enabled?).to(true)
    end
  end

  describe '#disable!' do
    let(:webhook) { Fabricate(:webhook, enabled: true) }

    it 'disables the webhook' do
      expect { webhook.disable! }
        .to change(webhook, :enabled?).to(false)
    end
  end
end
