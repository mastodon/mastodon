require 'rails_helper'

RSpec.describe BootstrapTimelineService, type: :service do
  subject { described_class.new }

  describe '#call' do
    let(:source_account) { Fabricate(:account) }

    context 'when setting is empty' do
      let!(:admin) { Fabricate(:user, admin: true) }

      before do
        Setting.bootstrap_timeline_accounts = nil
        subject.call(source_account)
      end

      it 'follows admin accounts from account' do
        expect(source_account.following?(admin.account)).to be true
      end
    end

    context 'when setting is set' do
      let!(:alice) { Fabricate(:account, username: 'alice') }
      let!(:bob)   { Fabricate(:account, username: 'bob') }
      let!(:eve)   { Fabricate(:account, username: 'eve', suspended: true) }

      before do
        Setting.bootstrap_timeline_accounts = 'alice, @bob, eve, unknown'
        subject.call(source_account)
      end

      it 'follows found accounts from account' do
        expect(source_account.following?(alice)).to be true
        expect(source_account.following?(bob)).to be true
      end

      it 'does not follow suspended account' do
        expect(source_account.following?(eve)).to be false
      end
    end
  end
end
