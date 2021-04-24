require 'rails_helper'

RSpec.describe Status, type: :model do
  describe '.as_tag_timeline' do
    let(:tag) { Fabricate(:tag) }
    let(:account) { Fabricate(:account) }

    it 'includes unlisted tagged statuses when account present' do
      unlisted_status = Fabricate(:status, tags: [tag], visibility: :unlisted)
      other = Fabricate(:status)

      results = Status.as_tag_timeline(tag, account)
      expect(results).to include(unlisted_status)
      expect(results).not_to include(other)
    end

    it 'no unlisted replies to be included' do
      original = Fabricate(:status)
      status = Fabricate(:status, tags: [tag], in_reply_to_id: original.id, visibility: :unlisted)

      results = Status.as_tag_timeline(tag, account)
      expect(results).not_to include(status)
    end
  end
end
