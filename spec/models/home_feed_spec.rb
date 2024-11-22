# frozen_string_literal: true

require 'rails_helper'

RSpec.describe HomeFeed do
  subject { described_class.new(account) }

  let(:account) { Fabricate(:account) }

  describe '#get' do
    before do
      Fabricate(:status, account: account, id: 1)
      Fabricate(:status, account: account, id: 2)
      Fabricate(:status, account: account, id: 3)
      Fabricate(:status, account: account, id: 10)
    end

    context 'when feed is generated' do
      before do
        redis.zadd(
          FeedManager.instance.key(:home, account.id),
          [[4, 4], [3, 3], [2, 2], [1, 1]]
        )
      end

      it 'gets statuses with ids in the range from redis' do
        results = subject.get(3)

        expect(results.map(&:id)).to eq [3, 2]
      end
    end

    context 'when feed is being generated' do
      before do
        redis.set("account:#{account.id}:regeneration", true)
      end

      it 'returns nothing' do
        results = subject.get(3)

        expect(results.map(&:id)).to eq []
      end
    end
  end
end
