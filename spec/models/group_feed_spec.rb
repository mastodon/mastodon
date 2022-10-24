require 'rails_helper'

RSpec.describe GroupFeed, type: :model do
  let(:group)   { Fabricate(:group) }
  let(:member1) { Fabricate(:group_membership, group: group).account }
  let(:member2) { Fabricate(:group_membership, group: group).account }
  let(:member3) { Fabricate(:group_membership, group: group).account }

  let!(:status1) { Fabricate(:status, account: member1, group: group, visibility: :group) }
  let!(:status2) { Fabricate(:status, account: member2, group: group, visibility: :group) }
  let!(:status3) { Fabricate(:status, account: member3, group: group, visibility: :group, approval_status: :approved) }
  let!(:status4) { Fabricate(:status, account: member1) }
  let!(:status5) { Fabricate(:status, account: member2) }
  let!(:status6) { Fabricate(:status, account: member3) }
  let!(:status7) { Fabricate(:status, account: member1, group: group, visibility: :group, approval_status: :pending) }
  let!(:status8) { Fabricate(:status, account: member2, group: group, visibility: :group, approval_status: :revoked) }
  let!(:status9) { Fabricate(:status, account: member3, group: group, visibility: :group, approval_status: :rejected) }

  describe '#get' do
    context 'without a logged-in viewer' do
      subject { described_class.new(group, nil) }

      it 'returns group posts in reverse-chronological order' do
        expect(subject.get(10)).to eq [status3, status2, status1]
      end
    end

    context 'with a logged-in viewer' do
      let(:viewer) { Fabricate(:account) }

      subject { described_class.new(group, viewer) }

      before do
        viewer.block!(member2)
      end

      it 'returns group posts in reverse-chronological order, excluding blocked users' do
        expect(subject.get(10)).to eq [status3, status1]
      end

      it 'returns unapproved self-posts' do
        group.memberships.create!(account: viewer)
        unapproved = Fabricate(:status, group: group, visibility: :group, approval_status: :pending, account: viewer)
        unrelated  = Fabricate(:status, account: viewer)

        expect(subject.get(10)).to eq [unapproved, status3, status1]
      end
    end
  end
end
