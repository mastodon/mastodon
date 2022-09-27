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
end
