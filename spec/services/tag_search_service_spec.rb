# frozen_string_literal: true

require 'rails_helper'

describe TagSearchService do
  describe '.call' do
    context 'if account is present' do
      let(:account) { Fabricate(:account) }

      it 'orders by recent use' do
        a = Fabricate(:tag, name: 'a')
        b = Fabricate(:tag, name: 'b')
        Fabricate(:recently_used_tag, account: account, index: 1, tag: a)
        Fabricate(:recently_used_tag, account: account, index: 2, tag: b)

        names = TagSearchService.new.call('', 2, account).pluck(:name)

        expect(names[0]).to eq 'b'
        expect(names[1]).to eq 'a'
      end

      it 'limits recently used tags' do
        2.times.each { |index| Fabricate(:recently_used_tag, account: account, index: index) }
        expect(TagSearchService.new.call('', 1, account).size).to eq 1
      end

      it 'limits recently unused tags' do
        Fabricate(:recently_used_tag, account: account)
        Fabricate(:tag)
        expect(TagSearchService.new.call('', 1, account).size).to eq 1
      end

      it 'does not duplicate recently used tags' do
        Fabricate(:recently_used_tag, account: account)
        expect(TagSearchService.new.call('', 2, account).size).to eq 1
      end
    end

    context 'if account is not present' do
      it 'does not raise error' do
        expect{ TagSearchService.new.call('', 1) }.not_to raise_error
      end
    end

    it 'removes # prefix from query' do
      Fabricate(:tag, name: 'name')
      expect(TagSearchService.new.call('#name', 1).pluck(:name)).to include 'name'
    end

    it 'strips query' do
      Fabricate(:tag, name: 'name')
      expect(TagSearchService.new.call(' name ', 1).pluck(:name)).to include 'name'
    end
  end
end
