# frozen_string_literal: true

require 'rails_helper'

describe TagFeed do
  describe '#get' do
    let(:account) { Fabricate(:account) }
    let(:tag_cats) { Fabricate(:tag, name: 'cats') }
    let(:tag_dogs) { Fabricate(:tag, name: 'dogs') }
    let!(:status_tagged_with_cats) { Fabricate(:status, tags: [tag_cats]) }
    let!(:status_tagged_with_dogs) { Fabricate(:status, tags: [tag_dogs]) }
    let!(:both) { Fabricate(:status, tags: [tag_cats, tag_dogs]) }

    it 'can add tags in "any" mode' do
      results = described_class.new(tag_cats, nil, any: [tag_dogs.name]).get(20)
      expect(results).to include status_tagged_with_cats
      expect(results).to include status_tagged_with_dogs
      expect(results).to include both
    end

    it 'can remove tags in "all" mode' do
      results = described_class.new(tag_cats, nil, all: [tag_dogs.name]).get(20)
      expect(results).to_not include status_tagged_with_cats
      expect(results).to_not include status_tagged_with_dogs
      expect(results).to     include both
    end

    it 'can remove tags in "none" mode' do
      results = described_class.new(tag_cats, nil, none: [tag_dogs.name]).get(20)
      expect(results).to     include status_tagged_with_cats
      expect(results).to_not include status_tagged_with_dogs
      expect(results).to_not include both
    end

    it 'ignores an invalid mode' do
      results = described_class.new(tag_cats, nil, wark: [tag_dogs.name]).get(20)
      expect(results).to     include status_tagged_with_cats
      expect(results).to_not include status_tagged_with_dogs
      expect(results).to     include both
    end

    it 'handles being passed non existent tag names' do
      results = described_class.new(tag_cats, nil, any: ['wark']).get(20)
      expect(results).to     include status_tagged_with_cats
      expect(results).to_not include status_tagged_with_dogs
      expect(results).to     include both
    end

    it 'can restrict to an account' do
      BlockService.new.call(account, status_tagged_with_cats.account)
      results = described_class.new(tag_cats, account, none: [tag_dogs.name]).get(20)
      expect(results).to_not include status_tagged_with_cats
    end

    it 'can restrict to local' do
      status_tagged_with_cats.account.update(domain: 'example.com')
      status_tagged_with_cats.update(local: false, uri: 'example.com/toot')
      results = described_class.new(tag_cats, nil, any: [tag_dogs.name], local: true).get(20)
      expect(results).to_not include status_tagged_with_cats
    end

    it 'allows replies to be included' do
      original = Fabricate(:status)
      status = Fabricate(:status, tags: [tag_cats], in_reply_to_id: original.id)

      results = described_class.new(tag_cats, nil).get(20)
      expect(results).to include(status)
    end

    context 'when the feed contains a local-only status' do
      let!(:status) { Fabricate(:status, tags: [tag_cats], local_only: true) }

      it 'does not show local-only statuses without a viewer' do
        results = described_class.new(tag_cats, nil).get(20)
        expect(results).to_not include(status)
      end

      it 'shows local-only statuses given a viewer' do
        results = described_class.new(tag_cats, account).get(20)
        expect(results).to include(status)
      end
    end
  end
end
