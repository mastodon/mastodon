# frozen_string_literal: true

RSpec.shared_examples 'RankedTrend' do
  describe 'Scopes' do
    describe '.by_rank' do
      let!(:lower_rank) { Fabricate factory_name, rank: 5 }
      let!(:higher_rank) { Fabricate factory_name, rank: 50 }

      it 'returns records ordered by rank' do
        expect(described_class.by_rank)
          .to eq([higher_rank, lower_rank])
      end
    end

    describe '.ranked_below' do
      let!(:low_rank) { Fabricate factory_name, rank: 5 }
      let!(:med_rank) { Fabricate factory_name, rank: 50 }
      let!(:high_rank) { Fabricate factory_name, rank: 500 }

      it 'returns records ordered by rank' do
        expect(described_class.ranked_below(100))
          .to include(low_rank)
          .and include(med_rank)
          .and not_include(high_rank)
      end
    end
  end

  describe '.locales' do
    before do
      Fabricate.times 2, factory_name, language: 'en'
      Fabricate factory_name, language: 'es'
    end

    it 'returns unique set of languages' do
      expect(described_class.locales)
        .to eq(['en', 'es'])
    end
  end

  describe '.recalculate_ordered_rank' do
    let!(:low_score) { Fabricate factory_name, score: 5, rank: 123 }
    let!(:high_score) { Fabricate factory_name, score: 10, rank: 456 }

    it 'ranks records based on their score' do
      expect { described_class.recalculate_ordered_rank }
        .to change { low_score.reload.rank }.to(2)
        .and change { high_score.reload.rank }.to(1)
    end
  end

  def factory_name
    described_class.name.underscore.to_sym
  end
end
