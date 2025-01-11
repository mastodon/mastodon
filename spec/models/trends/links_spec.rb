# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Trends::Links do
  describe 'Trends::Links::Query' do
    subject { described_class.new.query }

    describe '#records' do
      context 'with scored cards' do
        let!(:higher_score) { Fabricate :preview_card_trend, score: 10, language: 'en' }
        let!(:lower_score) { Fabricate :preview_card_trend, score: 1, language: 'es' }

        it 'returns higher score first' do
          expect(subject.records)
            .to eq([higher_score.preview_card, lower_score.preview_card])
        end

        context 'with preferred locale' do
          before { subject.in_locale!('es') }

          it 'returns in language order' do
            expect(subject.records)
              .to eq([lower_score.preview_card, higher_score.preview_card])
          end
        end

        context 'when account has chosen languages' do
          let!(:lang_match_higher_score) { Fabricate :preview_card_trend, score: 10, language: 'is' }
          let!(:lang_match_lower_score) { Fabricate :preview_card_trend, score: 1, language: 'da' }
          let(:user) { Fabricate :user, chosen_languages: %w(da is) }
          let(:account) { Fabricate :account, user: user }

          before { subject.filtered_for!(account) }

          it 'returns results' do
            expect(subject.records)
              .to eq([lang_match_higher_score.preview_card, lang_match_lower_score.preview_card, higher_score.preview_card, lower_score.preview_card])
          end
        end
      end
    end
  end
end
