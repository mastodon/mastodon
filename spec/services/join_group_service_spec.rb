require 'rails_helper'

RSpec.describe JoinGroupService, type: :service do
  let(:sender) { Fabricate(:account, username: 'alice') }

  subject { JoinGroupService.new }

  context 'local group' do
    describe 'locked group' do
      let(:group) { Fabricate(:group, locked: true) }

      before do
        subject.call(sender, group)
      end

      it 'creates a membership request' do
        expect(GroupMembershipRequest.find_by(account: sender, group: group)).to_not be_nil
      end

      it 'does not create a membership' do
        expect(GroupMembership.find_by(account: sender, group: group)).to be_nil
      end
    end

    describe 'unlocked group' do
      let(:group) { Fabricate(:group) }

      before do
        subject.call(sender, group)
      end

      it 'does not create a membership request' do
        expect(GroupMembershipRequest.find_by(account: sender, group: group)).to be_nil
      end

      it 'creates a membership' do
        expect(GroupMembership.find_by(account: sender, group: group)).to_not be_nil
      end
    end

    context 'when the account is blocked by the group' do
      let(:group) { Fabricate(:group) }

      before do
        GroupAccountBlock.create!(group: group, account: sender)
      end

      it 'raises an exception' do
        expect { subject.call(sender, group) }.to raise_error Mastodon::NotPermittedError
      end
    end
  end

  context 'remote ActivityPub group' do
    let(:group) { Fabricate(:group, domain: 'example.com', inbox_url: 'http://example.com/inbox') }

    before do
      stub_request(:post, "http://example.com/inbox").to_return(:status => 200, :body => "", :headers => {})
      subject.call(sender, group)
    end

    it 'creates membership request' do
      expect(GroupMembershipRequest.find_by(account: sender, group: group)).to_not be_nil
    end

    it 'sends a Join activity to the inbox' do
      expect(a_request(:post, 'http://example.com/inbox').with(
        headers: { 'Signature' => /keyId="#{Regexp.escape(ActivityPub::TagManager.instance.key_uri_for(sender))}"/ },
        body: /"Join"/,
      )).to have_been_made.once
    end
  end
end
