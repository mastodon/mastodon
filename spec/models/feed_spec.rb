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

      expect(results.map(&:id)).to eq [3, 2]
      expect(results.first.attributes.keys).to eq %w(id updated_at)
    end
  end
end
