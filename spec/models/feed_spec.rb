require 'rails_helper'

RSpec.describe Feed, type: :model do
  describe '#get' do
    it 'gets statuses with ids in the range' do
      account = Fabricate(:account)
      Fabricate(:status, account: account, id: 1)
      Fabricate(:status, account: account, id: 2)
      Fabricate(:status, account: account, id: 3)
      Fabricate(:status, account: account, id: 10)
      Redis.current.zadd(FeedManager.instance.key(:home, account.id),
                        [[4, 'deleted'], [3, 'val3'], [2, 'val2'], [1, 'val1']])

      feed = Feed.new(:home, account)
      results = feed.get(3)

      expect(results.map(&:id)).to eq [3, 2, 1]
      expect(results.first.attributes.keys).to eq %w(id updated_at)
    end

    it 'fall backs to database if Redis could not fill feed' do
      account = Fabricate(:account)
      statuses = 2.times.map { Fabricate(:status, account: account) }
      Redis.current.zadd(FeedManager.instance.key(:home, account.id), statuses[1].id, statuses[1].id)

      feed = Feed.new(:home, account)
      results = feed.get(2, nil, 0)

      expect(results.pluck(:id)).to eq statuses.pluck(:id).reverse
    end
  end
end
