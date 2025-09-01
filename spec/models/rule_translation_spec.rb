# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RuleTranslation do
  describe 'Associations' do
    it { is_expected.to belong_to(:rule) }
  end

  describe 'Validations' do
    subject { Fabricate.build :rule_translation }

    it { is_expected.to validate_presence_of(:language) }
    it { is_expected.to validate_presence_of(:text) }
    it { is_expected.to validate_length_of(:text).is_at_most(Rule::TEXT_SIZE_LIMIT) }
    it { is_expected.to validate_uniqueness_of(:language).scoped_to(:rule_id) }
  end

  describe 'Scopes' do
    describe '.for_locale' do
      let!(:matching) { Fabricate :rule_translation, language: 'en' }
      let!(:missing) { Fabricate :rule_translation, language: 'es' }

      context 'when sent top-level string' do
        it 'includes expected records' do
          results = described_class.for_locale('en')

          expect(results)
            .to include(matching)
            .and not_include(missing)
        end
      end

      context 'when sent sub string' do
        it 'includes expected records' do
          results = described_class.for_locale('en-US')

          expect(results)
            .to include(matching)
            .and not_include(missing)
        end
      end
    end

    describe '.by_language_length' do
      let!(:top_level) { Fabricate :rule_translation, language: 'en' }
      let!(:sub_level) { Fabricate :rule_translation, language: 'en-US' }

      it 'returns results ordered by length' do
        expect(described_class.by_language_length)
          .to eq([sub_level, top_level])
      end
    end
  end

  describe '.languages' do
    let(:discarded_rule) { Fabricate :rule, deleted_at: 5.days.ago }
    let(:kept_rule) { Fabricate :rule }

    before do
      Fabricate :rule_translation, rule: discarded_rule, language: 'en'
      Fabricate :rule_translation, rule: kept_rule, language: 'es'
      Fabricate :rule_translation, language: 'fr'
      Fabricate :rule_translation, language: 'es'
    end

    it 'returns ordered distinct languages connected to non-discarded rules' do
      expect(described_class.languages)
        .to be_an(Array)
        .and eq(%w(es fr))
    end
  end
end
