# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AccountSuggestions::FaspSource do
  describe '#get', feature: :fasp do
    subject { described_class.new }

    let(:bob) { Fabricate(:account) }
    let(:alice) { Fabricate(:account, domain: 'fedi.example.com') }
    let(:eve) { Fabricate(:account, domain: 'fedi.example.com') }

    before do
      [alice, eve].each do |recommended_account|
        Fasp::FollowRecommendation.create!(requesting_account: bob, recommended_account:)
      end
    end

    it 'returns recommendations obtained by FASP' do
      expect(subject.get(bob)).to contain_exactly([alice.id, :fasp], [eve.id, :fasp])
    end
  end
end
