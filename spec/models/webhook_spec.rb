# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Webhook do
  let(:webhook) { Fabricate(:webhook) }

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
