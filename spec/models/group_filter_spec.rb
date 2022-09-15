require 'rails_helper'

describe GroupFilter do
  describe 'with empty params' do
    it 'excludes instance actor by default' do
      filter = described_class.new({})

      expect(filter.results).to eq Group.unscoped
    end
  end

  describe 'with various filters' do
    let!(:group1) { Fabricate(:group, display_name: 'Mastodon test', domain: nil) }
    let!(:group2) { Fabricate(:group, display_name: 'Mastodon development', domain: 'mastodon.social', uri: 'https://mastodon.social/groups/1') }
    let!(:group3) { Fabricate(:group, display_name: 'Uninteresting news', domain: 'mastodon.social', uri: 'https://mastodon.social/groups/2') }
    let(:account) { Fabricate(:account) }

    before do
      group3.suspend!

      group1.memberships.create!(account: account)
      group3.memberships.create!(account: account)
    end

    it 'filters by origin and display_name' do
      filter = described_class.new({ display_name: 'Mastodon', origin: 'remote' })

      expect(filter.results.pluck(:id)).to match_array([group2.id])
    end

    it 'filters by domain and status' do
      filter = described_class.new({ by_domain: 'mastodon.social', status: 'suspended' })

      expect(filter.results.pluck(:id)).to match_array([group3.id])
    end

    it 'filters by member' do
      filter = described_class.new({ by_member: account.id })

      expect(filter.results.pluck(:id)).to match_array([group1.id, group3.id])
    end
  end

  describe 'with invalid params' do
    it 'raises with key error' do
      filter = described_class.new(wrong: true)

      expect { filter.results }.to raise_error(/wrong/)
    end
  end
end
