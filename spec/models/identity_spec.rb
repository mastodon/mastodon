# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Identity do
  describe '.find_for_omniauth' do
    let(:auth) { Fabricate(:identity, user: Fabricate(:user)) }

    it 'calls .find_or_create_by' do
      allow(described_class).to receive(:find_or_create_by)

      described_class.find_for_omniauth(auth)

      expect(described_class).to have_received(:find_or_create_by).with(uid: auth.uid, provider: auth.provider)
    end

    it 'returns an instance of Identity' do
      expect(described_class.find_for_omniauth(auth)).to be_instance_of described_class
    end
  end
end
