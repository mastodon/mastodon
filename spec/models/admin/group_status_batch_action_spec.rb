require 'rails_helper'

RSpec.describe Admin::GroupStatusBatchAction, type: :model do
  let(:batch_action) { described_class.new }

  describe '#save!' do
    subject              { batch_action.save! }
    let(:account)        { Fabricate(:user, role: UserRole.find_by(name: 'Admin')).account }
    let(:type)           { 'report' }
    let(:group)          { Fabricate(:group) }
    let(:account1)       { Fabricate(:group_membership, group: group).account }
    let(:account2)       { Fabricate(:group_membership, group: group).account }
    let(:statuses) do
      [
        Fabricate(:status, account: account1, visibility: 'group', group: group),
        Fabricate(:status, account: account1, visibility: 'group', group: group),
        Fabricate(:status, account: account2, visibility: 'group', group: group),
      ]
    end
    let(:status_ids) { statuses.map(&:id) }

    before do
      batch_action.assign_attributes(
        type:            type,
        current_account: account,
        status_ids:      status_ids
      )
    end

    context 'type is "report"' do
      let(:type) { 'report' }

      it 'creates the expected report objects' do
        expect { subject }.to change { [account1.targeted_reports.count, account2.targeted_reports.count] }.from([0, 0]).to([1, 1])
        expect(account1.targeted_reports.first.status_ids).to match_array([status_ids[0], status_ids[1]])
        expect(account2.targeted_reports.first.status_ids).to match_array([status_ids[2]])
      end
    end
  end
end
