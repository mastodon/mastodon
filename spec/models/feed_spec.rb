require 'rails_helper'

RSpec.describe Feed, type: :model do
  let(:account) { Fabricate(:account) }

  subject { described_class.new(:home, account) }

  describe '#get' do
    before do
      Fabricate(:status, account: account, id: 1)
      Fabricate(:status, account: account, id: 2)
      Fabricate(:status, account: account, id: 3)
      Fabricate(:status, account: account, id: 10)
    end

    context 'when feed is generated' do
      before do
        Redis.current.zadd(
          FeedManager.instance.key(:home, account.id),
          [[4, 4], [3, 3], [2, 2], [1, 1]]
        )
      end

      it 'gets statuses with ids in the range from redis' do
        results = subject.get(3)

        expect(results.map(&:id)).to eq [3, 2]
        expect(results.first.attributes.keys).to eq %w(id updated_at)
      end
    end

    context 'when feed is being generated' do
      before do
        Redis.current.set("account:#{account.id}:regeneration", true)
      end

      it 'gets statuses with ids in the range from database' do
        results = subject.get(3)

        expect(results.map(&:id)).to eq [10, 3, 2]
        expect(results.first.attributes.keys).to include('id', 'updated_at')
      end
    end
  end
end
