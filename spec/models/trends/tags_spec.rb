# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Trends::Tags do
  subject { described_class.new(threshold: 5, review_threshold: 10) }

  let!(:at_time) { DateTime.new(2021, 11, 14, 10, 15, 0) }

  describe '#add' do
    let(:tag) { Fabricate(:tag) }

    before do
      subject.add(tag, 1, at_time)
    end

    it 'records history' do
      expect(tag.history.get(at_time).accounts).to eq 1
    end

    it 'records use' do
      expect(subject.send(:recently_used_ids, at_time)).to eq [tag.id]
    end
  end

  describe '#query' do
    it 'returns a composable query scope' do
      expect(subject.query).to be_a Trends::Query
    end
  end

  describe 'Trends::Tags::Query' do
    subject { described_class.new.query }

    describe '#records' do
      context 'with scored cards' do
        let!(:higher_score) { Fabricate :tag_trend, score: 10, language: 'en' }
        let!(:lower_score) { Fabricate :tag_trend, score: 1, language: 'es' }

        it 'returns higher score first' do
          expect(subject.records)
            .to eq([higher_score.tag, lower_score.tag])
        end

        context 'with preferred locale' do
          before { subject.in_locale!('es') }

          it 'returns in language order' do
            expect(subject.records)
              .to eq([lower_score.tag, higher_score.tag])
          end
        end

        context 'when account has chosen languages' do
          let!(:lang_match_higher_score) { Fabricate :tag_trend, score: 10, language: 'is' }
          let!(:lang_match_lower_score) { Fabricate :tag_trend, score: 1, language: 'da' }
          let(:user) { Fabricate :user, chosen_languages: %w(da is) }
          let(:account) { Fabricate :account, user: user }

          before { subject.filtered_for!(account) }

          it 'returns results' do
            expect(subject.records)
              .to eq([lang_match_higher_score.tag, lang_match_lower_score.tag, higher_score.tag, lower_score.tag])
          end
        end
      end
    end
  end

  describe '#refresh' do
    let!(:today) { at_time }
    let!(:yesterday) { today - 1.day }

    let!(:tag_cats) { Fabricate(:tag, name: 'Catstodon', trendable: true) }
    let!(:tag_dogs) { Fabricate(:tag, name: 'DogsOfMastodon', trendable: true) }
    let!(:tag_ocs) { Fabricate(:tag, name: 'OCs', trendable: true) }

    before do
      2.times  { |i| subject.add(tag_cats, i, yesterday) }
      13.times { |i| subject.add(tag_ocs, i, yesterday) }
      16.times { |i| subject.add(tag_cats, i, today) }
      4.times  { |i| subject.add(tag_dogs, i, today) }
    end

    context 'when tag trends are refreshed' do
      before do
        subject.refresh(yesterday + 12.hours)
        subject.refresh(at_time)
      end

      it 'calculates and re-calculates scores' do
        expect(subject.query.limit(10).to_a).to eq [tag_cats, tag_ocs]
      end

      it 'omits hashtags below threshold' do
        expect(subject.query.limit(10).to_a).to_not include(tag_dogs)
      end
    end

    it 'decays scores' do
      subject.refresh(yesterday + 12.hours)
      original_score = TagTrend.find_by(tag: tag_ocs).score
      expect(original_score).to eq 144.0
      subject.refresh(yesterday + 12.hours + subject.options[:max_score_halflife])
      decayed_score = TagTrend.find_by(tag: tag_ocs).score
      expect(decayed_score).to be <= original_score / 2
    end
  end
end
