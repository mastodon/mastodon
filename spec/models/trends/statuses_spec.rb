# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Trends::Statuses do
  subject! { described_class.new(threshold: 5, review_threshold: 10, score_halflife: 8.hours) }

  let!(:at_time) { DateTime.new(2021, 11, 14, 10, 15, 0) }

  describe 'Trends::Statuses::Query' do
    let!(:query) { subject.query }
    let!(:today) { at_time }

    let!(:status_foo) { Fabricate(:status, text: 'Foo', language: 'en', trendable: true, created_at: today) }
    let!(:status_bar) { Fabricate(:status, text: 'Bar', language: 'en', trendable: true, created_at: today) }

    before do
      default_threshold_value.times { reblog(status_foo, today) }
      default_threshold_value.times { reblog(status_bar, today) }

      subject.refresh(today)
    end

    describe '#filtered_for' do
      let(:account) { Fabricate(:account) }

      it 'returns a composable query scope' do
        expect(query.filtered_for(account)).to be_a Trends::Query
      end

      it 'filters out blocked accounts' do
        account.block!(status_foo.account)
        expect(query.filtered_for(account).to_a).to eq [status_bar]
      end

      it 'filters out muted accounts' do
        account.mute!(status_bar.account)
        expect(query.filtered_for(account).to_a).to eq [status_foo]
      end

      it 'filters out blocked-by accounts' do
        status_foo.account.block!(account)
        expect(query.filtered_for(account).to_a).to eq [status_bar]
      end
    end
  end

  describe '#add' do
    let(:status) { Fabricate(:status) }

    before do
      subject.add(status, 1, at_time)
    end

    it 'records use' do
      expect(subject.send(:recently_used_ids, at_time)).to eq [status.id]
    end
  end

  describe '#query' do
    it 'returns a composable query scope' do
      expect(subject.query).to be_a Trends::Query
    end

    it 'responds to filtered_for' do
      expect(subject.query).to respond_to(:filtered_for)
    end
  end

  describe '#refresh' do
    let!(:today) { at_time }
    let!(:yesterday) { today - 1.day }

    let!(:status_foo) { Fabricate(:status, text: 'Foo', language: 'en', trendable: true, created_at: yesterday) }
    let!(:status_bar) { Fabricate(:status, text: 'Bar', language: 'en', trendable: true, created_at: today) }
    let!(:status_baz) { Fabricate(:status, text: 'Baz', language: 'en', trendable: true, created_at: today) }

    before do
      default_threshold_value.times { reblog(status_foo, today) }
      default_threshold_value.times { reblog(status_bar, today) }
      (default_threshold_value - 1).times { reblog(status_baz, today) }
    end

    context 'when status trends are refreshed' do
      before do
        subject.refresh(today)
      end

      it 'returns correct statuses from query' do
        results = subject.query.limit(10).to_a

        expect(results).to eq [status_bar, status_foo]
        expect(results).to_not include(status_baz)
      end
    end

    it 'decays scores' do
      subject.refresh(today)
      original_score = status_bar.trend.score
      expect(original_score).to be_a Float
      subject.refresh(today + subject.options[:score_halflife])
      decayed_score = status_bar.trend.reload.score
      expect(decayed_score).to be <= original_score / 2
    end
  end

  def reblog(status, at_time)
    reblog = Fabricate(:status, reblog: status, created_at: at_time)
    subject.add(status, reblog.account_id, at_time)
  end

  def default_threshold_value
    described_class.default_options[:threshold]
  end
end
