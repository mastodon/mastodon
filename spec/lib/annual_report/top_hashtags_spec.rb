# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AnnualReport::TopHashtags do
  describe '#generate' do
    subject { described_class.new(account, Time.zone.now.year) }

    context 'with an inactive account' do
      let(:account) { Fabricate :account }

      it 'builds a report for an account' do
        expect(subject.generate)
          .to include(
            top_hashtags: be_an(Array).and(be_empty)
          )
      end
    end

    context 'with an active account' do
      let(:account) { Fabricate :account }

      let(:tag) { Fabricate :tag }

      before do
        _other = Fabricate :status
        first = Fabricate :status, account: account
        first.tags << tag
        last = Fabricate :status, account: account
        last.tags << tag
      end

      it 'builds a report for an account' do
        expect(subject.generate)
          .to include(
            top_hashtags: contain_exactly(
              include(name: tag.name, count: 2)
            )
          )
      end
    end
  end
end
