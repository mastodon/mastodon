# frozen_string_literal: true

require 'rails_helper'

RSpec.describe StatusTrend do
  it_behaves_like 'RankedTrend'

  describe 'Associations' do
    it { is_expected.to belong_to(:account).required }
    it { is_expected.to belong_to(:status).required }
  end

  describe 'Scopes' do
    describe '.allowed' do
      context 'with multiple trends per account' do
        let(:account) { Fabricate :account }
        let!(:allowed_high_score) { Fabricate :status_trend, allowed: true, score: 10, account: }

        before do
          Fabricate :status_trend, allowed: false, score: 25
          Fabricate :status_trend, allowed: true, score: 2, account:
        end

        it 'returns allowed records with account grouped max scores' do
          expect(described_class.allowed)
            .to contain_exactly(eq(allowed_high_score).and(have_attributes(score: 10)))
        end
      end
    end
  end
end
