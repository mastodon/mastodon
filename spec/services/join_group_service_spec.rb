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
end
