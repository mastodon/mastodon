require 'rails_helper'

describe HashtagQueryService, type: :service do
  describe '.call' do
    let(:account) { Fabricate(:account) }
    let(:tag1) { Fabricate(:tag) }
    let(:tag2) { Fabricate(:tag) }
    let!(:status1) { Fabricate(:status, tags: [tag1]) }
    let!(:status2) { Fabricate(:status, tags: [tag2]) }
    let!(:both) { Fabricate(:status, tags: [tag1, tag2]) }

    it 'can add tags in "any" mode' do
      results = subject.call(tag1, { any: [tag2.name] })
      expect(results).to include status1
      expect(results).to include status2
      expect(results).to include both
    end

    it 'can remove tags in "all" mode' do
      results = subject.call(tag1, { all: [tag2.name] })
      expect(results).to_not include status1
      expect(results).to_not include status2
      expect(results).to     include both
    end

    it 'can remove tags in "none" mode' do
      results = subject.call(tag1, { none: [tag2.name] })
      expect(results).to     include status1
      expect(results).to_not include status2
      expect(results).to_not include both
    end

    it 'ignores an invalid mode' do
      results = subject.call(tag1, { wark: [tag2.name] })
      expect(results).to     include status1
      expect(results).to_not include status2
      expect(results).to     include both
    end

    it 'handles being passed non existant tag names' do
      results = subject.call(tag1, { any: ['wark'] })
      expect(results).to     include status1
      expect(results).to_not include status2
      expect(results).to     include both
    end

    it 'can restrict to an account' do
      BlockService.new.call(account, status1.account)
      results = subject.call(tag1, { none: [tag2.name] }, account)
      expect(results).to_not include status1
    end

    it 'can restrict to local' do
      status1.account.update(domain: 'example.com')
      status1.update(local: false, uri: 'example.com/toot')
      results = subject.call(tag1, { any: [tag2.name] }, nil, true)
      expect(results).to_not include status1
    end
  end
end
