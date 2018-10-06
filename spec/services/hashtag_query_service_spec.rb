require 'rails_helper'

describe HashtagQueryService, type: :service do
  describe '.call' do
    let(:tag1) { Fabricate(:tag) }
    let(:tag2) { Fabricate(:tag) }
    let!(:status1) { Fabricate(:status, tags: [tag1]) }
    let!(:status2) { Fabricate(:status, tags: [tag2]) }
    let!(:both) { Fabricate(:status, tags: [tag1, tag2]) }

    it 'can add tags in "any" mode' do
      results = subject.call(Status.all, [tag1, tag2], :any)
      expect(results).to include status1
      expect(results).to include status2
      expect(results).to include both
    end

    it 'can remove tags in "all" mode' do
      results = subject.call(Status.all, [tag1, tag2], :all)
      expect(results).to_not include status1
      expect(results).to_not include status2
      expect(results).to include both
    end

    it 'can remove tags in "none" mode' do
      results = subject.call(Status.all, [tag1], :none)
      expect(results).to_not include status1
      expect(results).to include status2
      expect(results).to_not include both
    end
  end
end
