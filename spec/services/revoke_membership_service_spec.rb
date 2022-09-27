require 'rails_helper'

RSpec.describe RevokeMembershipService, type: :service do
  let(:sender) { Fabricate(:account, username: 'alice') }
  let(:group) { Fabricate(:group) }
  let!(:membership) { Fabricate(:group_membership, group: group, account: sender) }

  subject { RevokeMembershipService.new }

  before do
    subject.call(membership)
  end

  it 'removes the membership' do
    expect { membership.reload }.to raise_error(ActiveRecord::RecordNotFound)
  end
end
