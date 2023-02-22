# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Identity, type: :model do
  describe '.find_for_oauth' do
    let(:auth) { Fabricate.build(:identity, user: Fabricate(:user)) }

    it 'calls .find_or_create_by' do
      expect(described_class).to receive(:find_or_create_by).with(uid: auth.uid, provider: auth.provider)
      described_class.find_for_oauth(auth)
    end

    it 'returns an instance of Identity' do
      expect(described_class.find_for_oauth(auth)).to be_instance_of Identity
    end
  end
end
