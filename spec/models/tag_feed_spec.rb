# frozen_string_literal: true

require 'rails_helper'

describe TagFeed, type: :service do
  describe '#get' do
    let(:account) { Fabricate(:account) }
    let(:tag1) { Fabricate(:tag) }
    let(:tag2) { Fabricate(:tag) }
    let!(:status1) { Fabricate(:status, tags: [tag1]) }
    let!(:status2) { Fabricate(:status, tags: [tag2]) }
    let!(:both) { Fabricate(:status, tags: [tag1, tag2]) }

    it 'can add tags in "any" mode' do
      results = described_class.new(tag1, nil, any: [tag2.name]).get(20)
      expect(results).to include status1
      expect(results).to include status2
      expect(results).to include both
    end

    it 'can remove tags in "all" mode' do
      results = described_class.new(tag1, nil, all: [tag2.name]).get(20)
      expect(results).to_not include status1
      expect(results).to_not include status2
      expect(results).to     include both
    end

    it 'can remove tags in "none" mode' do
      results = described_class.new(tag1, nil, none: [tag2.name]).get(20)
      expect(results).to     include status1
      expect(results).to_not include status2
      expect(results).to_not include both
    end

    it 'ignores an invalid mode' do
      results = described_class.new(tag1, nil, wark: [tag2.name]).get(20)
      expect(results).to     include status1
      expect(results).to_not include status2
      expect(results).to     include both
    end

    it 'handles being passed non existent tag names' do
      results = described_class.new(tag1, nil, any: ['wark']).get(20)
      expect(results).to     include status1
      expect(results).to_not include status2
      expect(results).to     include both
    end

    it 'can restrict to an account' do
      BlockService.new.call(account, status1.account)
      results = described_class.new(tag1, account, none: [tag2.name]).get(20)
      expect(results).to_not include status1
    end

    it 'can restrict to local' do
      status1.account.update(domain: 'example.com')
      status1.update(local: false, uri: 'example.com/toot')
      results = described_class.new(tag1, nil, any: [tag2.name], local: true).get(20)
      expect(results).to_not include status1
    end

    it 'allows replies to be included' do
      original = Fabricate(:status)
      status = Fabricate(:status, tags: [tag1], in_reply_to_id: original.id)

      results = described_class.new(tag1, nil).get(20)
      expect(results).to include(status)
    end
  end
end
