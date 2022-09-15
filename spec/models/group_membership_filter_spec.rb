# frozen_string_literal: true

require 'rails_helper'

describe GroupMembershipFilter do
  let(:group) { Fabricate(:group) }

  describe '#results' do
    context 'when default params are used' do
      let(:subject) do
        GroupMembershipFilter.new(group, 'order' => 'active').results
      end

      before do
        add_member_account_with(last_status_at: 7.days.ago)
        add_member_account_with(last_status_at: 1.day.ago)
        add_member_account_with(last_status_at: 3.days.ago)
      end

      it 'returns followings ordered by last activity' do
        expected_result = group.members.eager_load(:account_stat).reorder(nil).by_recent_status

        expect(subject).to eq expected_result
      end
    end
  end

  def add_member_account_with(last_status_at:)
    member_account = Fabricate(:account)
    Fabricate(:account_stat, account: member_account,
                             last_status_at: last_status_at,
                             statuses_count: 1,
                             following_count: 0,
                             followers_count: 0)
    Fabricate(:group_membership, group: group, account: member_account).account
  end
end

