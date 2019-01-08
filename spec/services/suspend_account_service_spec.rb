require 'rails_helper'

RSpec.describe SuspendAccountService, type: :service do
  describe '#call' do
    subject do
      -> { described_class.new.call(account) }
    end

    let!(:account) { Fabricate(:account) }
    let!(:status) { Fabricate(:status, account: account) }
    let!(:media_attachment) { Fabricate(:media_attachment, account: account) }
    let!(:notification) { Fabricate(:notification, account: account) }
    let!(:favourite) { Fabricate(:favourite, account: account) }
    let!(:active_relationship) { Fabricate(:follow, account: account) }
    let!(:passive_relationship) { Fabricate(:follow, target_account: account) }
    let!(:subscription) { Fabricate(:subscription, account: account) }

    it 'deletes associated records' do
      is_expected.to change {
        [
          account.statuses,
          account.media_attachments,
          account.stream_entries,
          account.notifications,
          account.favourites,
          account.active_relationships,
          account.passive_relationships,
          account.subscriptions
        ].map(&:count)
      }.from([1, 1, 1, 1, 1, 1, 1, 1]).to([0, 0, 0, 0, 0, 0, 0, 0])
    end
  end
end
