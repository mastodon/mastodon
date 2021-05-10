require 'rails_helper'

describe TagFeed, type: :service do
  describe '#get' do
    let(:account) { Fabricate(:account) }
    let(:tag) { Fabricate(:tag) }

    it 'includes no unlisted tagged statuses when account absent' do
      unlisted_status = Fabricate(:status, tags: [tag], visibility: :unlisted)
      other = Fabricate(:status)

      results = described_class.new(tag, nil).get(20)
      expect(results).not_to include(unlisted_status)
      expect(results).not_to include(other)
    end

    it 'no unlisted replies to be included when account absent' do
      original = Fabricate(:status)
      status = Fabricate(:status, tags: [tag], in_reply_to_id: original.id, visibility: :unlisted)

      results = described_class.new(tag, nil).get(20)
      expect(results).not_to include(status)
    end

    it 'includes unlisted tagged statuses when account present' do
      unlisted_status = Fabricate(:status, tags: [tag], visibility: :unlisted)
      other = Fabricate(:status)

      results = described_class.new(tag, account).get(20)
      expect(results).to include(unlisted_status)
      expect(results).not_to include(other)
    end

    it 'no unlisted replies to be included, even if account present' do
      original = Fabricate(:status)
      status = Fabricate(:status, tags: [tag], in_reply_to_id: original.id, visibility: :unlisted)

      results = described_class.new(tag, account).get(20)
      expect(results).not_to include(status)
    end
  end
end
