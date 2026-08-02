# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Account::Merging do
  let!(:account) { Fabricate(:account) }

  describe '#merge_with!' do
    let(:other_account) { Fabricate(:account) }
    let!(:status) { Fabricate(:status, account: other_account) }
    let!(:follow) { Fabricate(:follow, account: other_account) }
    let!(:reverse_follow) { Fabricate(:follow, target_account: other_account) }

    it 'reattributes records' do
      expect { account.merge_with!(other_account) }
        .to change { status.reload.account_id }.to(account.id)
        .and change { follow.reload.account_id }.to(account.id)
        .and change { reverse_follow.reload.target_account_id }.to(account.id)
    end
  end
end
