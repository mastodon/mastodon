require 'rails_helper'

RSpec.describe Feed, type: :model do
  describe '#get' do
    it 'gets statuses with ids in the range, maintining the order from Redis' do
      account = Fabricate(:account)
      Fabricate(:status, account: account, id: 1)
      Fabricate(:status, account: account, id: 2)
      Fabricate(:status, account: account, id: 3)
      Fabricate(:status, account: account, id: 10)
      redis = double(zrevrangebyscore: [['val2', 2.0], ['val1', 1.0], ['val3', 3.0], ['deleted', 4.0]], exists: false)
      allow(Redis).to receive(:current).and_return(redis)

      feed = Feed.new(:home, account)
      results = feed.get(3)

      expect(results.map(&:id)).to eq [2, 1, 3]
      expect(results.first.attributes.keys).to eq %w(id updated_at)
    end
  end
end
