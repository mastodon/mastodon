require 'rails_helper'

RSpec.describe HomeFeed, type: :model do
  let(:account)  { Fabricate(:account) }
  let(:followed) { Fabricate(:account) }
  let(:other)    { Fabricate(:account) }

  subject { described_class.new(account) }

  describe '#get' do
    before do
      account.follow!(followed)

      Fabricate(:status, account: account,  id: 1)
      Fabricate(:status, account: account,  id: 2)
      status = Fabricate(:status, account: followed, id: 3)
      Fabricate(:mention, account: account, status: status)
      Fabricate(:status, account: account,  id: 10)
      Fabricate(:status, account: other,    id: 11)
      Fabricate(:status, account: followed, id: 12, visibility: :private)
      Fabricate(:status, account: followed, id: 13, visibility: :direct)
      Fabricate(:status, account: account,  id: 14, visibility: :direct)
      dm = Fabricate(:status, account: followed, id: 15, visibility: :direct)
      Fabricate(:mention, account: account, status: dm)
    end

    context 'when feed is generated' do
      before do
        FeedManager.instance.populate_home(account)

        # Add direct messages because populate_home does not do that
        Redis.current.zadd(
          FeedManager.instance.key(:home, account.id),
          [[14, 14], [15, 15]]
        )
      end

      it 'gets statuses with ids in the range from redis with database' do
        results = subject.get(5)

        expect(results.map(&:id)).to eq [15, 14, 12, 10, 3]
        expect(results.first.attributes.keys).to eq %w(id updated_at)
      end

      it 'with since_id present' do
        results = subject.get(5, nil, 3, nil)
        expect(results.map(&:id)).to eq [15, 14, 12, 10]
      end

      it 'with min_id present' do
        results = subject.get(3, nil, nil, 0)
        expect(results.map(&:id)).to eq [3, 2, 1]
      end
    end

    context 'when feed is only partial' do
      before do
        FeedManager.instance.populate_home(account)

        # Add direct messages because populate_home does not do that
        Redis.current.zadd(
          FeedManager.instance.key(:home, account.id),
          [[14, 14], [15, 15]]
        )

        Redis.current.zremrangebyrank(FeedManager.instance.key(:home, account.id), 0, -2)
      end

      it 'gets statuses with ids in the range from redis with database' do
        results = subject.get(5)

        expect(results.map(&:id)).to eq [15, 14, 12, 10, 3]
        expect(results.first.attributes.keys).to eq %w(id updated_at)
      end

      it 'with since_id present' do
        results = subject.get(5, nil, 3, nil)
        expect(results.map(&:id)).to eq [15, 14, 12, 10]
      end

      it 'with min_id present' do
        results = subject.get(3, nil, nil, 0)
        expect(results.map(&:id)).to eq [3, 2, 1]
      end
    end

    context 'when feed is being generated' do
      before do
        Redis.current.set("account:#{account.id}:regeneration", true)
      end

      it 'returns from database' do
        results = subject.get(5)

        expect(results.map(&:id)).to eq [15, 14, 12, 10, 3]
      end

      it 'with since_id present' do
        results = subject.get(5, nil, 3, nil)
        expect(results.map(&:id)).to eq [15, 14, 12, 10]
      end

      it 'with min_id present' do
        results = subject.get(3, nil, nil, 0)
        expect(results.map(&:id)).to eq [3, 2, 1]
      end
    end
  end
end
