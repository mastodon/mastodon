require 'rails_helper'

RSpec.describe LeaveGroupService, type: :service do
  let(:sender) { Fabricate(:account, username: 'alice') }

  subject { LeaveGroupService.new }

  describe 'local' do
    let(:group) { Fabricate(:group, locked: true) }

    context 'when the user is a member of the group' do
      before do
        group.memberships.create!(account: sender)
        subject.call(sender, group)
      end

      it 'destroys the membership relation' do
        expect(GroupMembership.find_by(account: sender, group: group)).to be_nil
      end
    end

    context 'when the user has requested to be part of the group' do
      before do
        group.membership_requests.create!(account: sender)
        subject.call(sender, group)
      end

      it 'destroys the membership request' do
        expect(GroupMembershipRequest.find_by(account: sender, group: group)).to be_nil
      end
    end
  end

  describe 'remote ActivityPub' do
    let(:group) { Fabricate(:group, locked: true, domain: 'example.com', inbox_url: 'http://example.com/inbox') }

    before do
      group.memberships.create!(account: sender)
      stub_request(:post, 'http://example.com/inbox').to_return(status: 200)
      subject.call(sender, group)
    end

    it 'destroys the following relation' do
        expect(GroupMembershipRequest.find_by(account: sender, group: group)).to be_nil
    end

    it 'sends an Undo activity' do
      expect(a_request(:post, 'http://example.com/inbox').with(
        headers: { 'Signature' => /keyId="#{Regexp.escape(ActivityPub::TagManager.instance.key_uri_for(sender))}"/ },
        body: /"Undo"/,
      )).to have_been_made.once
    end

    it 'sends a Leave activity' do
      expect(a_request(:post, 'http://example.com/inbox').with(
        headers: { 'Signature' => /keyId="#{Regexp.escape(ActivityPub::TagManager.instance.key_uri_for(sender))}"/ },
        body: /"Leave"/,
      )).to have_been_made.once
    end
  end
end
