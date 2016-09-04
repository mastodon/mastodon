require 'rails_helper'

RSpec.describe ApplicationHelper, type: :helper do
  let(:local_domain) { Rails.configuration.x.local_domain }

  describe '#unique_tag' do
    it 'returns a string' do
      expect(helper.unique_tag(Time.now, 12, 'Status')).to be_a String
    end
  end

  describe '#unique_tag_to_local_id' do
    it 'returns the ID part' do
      expect(helper.unique_tag_to_local_id("tag:#{local_domain};objectId=12:objectType=Status", 'Status')).to eql '12'
    end
  end

  describe '#local_id?' do
    it 'returns true for a local ID' do
      expect(helper.local_id?("tag:#{local_domain};objectId=12:objectType=Status")).to be true
    end

    it 'returns false for a foreign ID' do
      expect(helper.local_id?('tag:foreign.tld;objectId=12:objectType=Status')).to be false
    end
  end

  describe '#linkify' do
    let(:alice) { Fabricate(:account, username: 'alice') }
    let(:bob) { Fabricate(:account, username: 'bob', domain: 'example.com', url: 'http://example.com/bob') }

    it 'turns mention of remote user into link' do
      status = Fabricate(:status, text: 'Hello @bob@example.com', account: bob)
      status.mentions.create(account: bob)
      expect(helper.linkify(status)).to match('<a href="http://example.com/bob" class="mention">@<span>bob@example.com</span></a>')
    end

    it 'turns mention of local user into link' do
      status = Fabricate(:status, text: 'Hello @alice', account: bob)
      status.mentions.create(account: alice)
      expect(helper.linkify(status)).to match('<a href="http://test.host/users/alice" class="mention">@<span>alice</span></a>')
    end

    it 'leaves mention of unresolvable user alone' do
      status = Fabricate(:status, text: 'Hello @foo', account: bob)
      expect(helper.linkify(status)).to match('Hello @foo')
    end
  end

  describe '#account_from_mentions' do
    let(:bob) { Fabricate(:account, username: 'bob', domain: 'example.com') }
    let(:status) { Fabricate(:status, text: 'Hello @bob@example.com', account: bob) }
    let(:mentions) { [Mention.create(status: status, account: bob)] }

    it 'returns account' do
      expect(helper.account_from_mentions('bob@example.com', mentions)).to eq bob
    end
  end
end
