require 'rails_helper'

RSpec.describe ImportService, type: :service do
  let!(:account) { Fabricate(:account) }
  let!(:bob)     { Fabricate(:account, username: 'bob') }
  let!(:eve)     { Fabricate(:account, username: 'eve', domain: 'example.com') }

  context 'import old-style list of muted users' do
    subject { ImportService.new }

    let(:csv) { attachment_fixture('mute-imports.txt') }

    describe 'when no accounts are muted' do
      let(:import) { Import.create(account: account, type: 'muting', data: csv) }
      it 'mutes the listed accounts, including notifications' do
        subject.call(import)
        expect(account.muting.count).to eq 2
        expect(Mute.find_by(account: account, target_account: bob).hide_notifications).to be true
      end
    end

    describe 'when some accounts are muted and overwrite is not set' do
      let(:import) { Import.create(account: account, type: 'muting', data: csv) }

      it 'mutes the listed accounts, including notifications' do
        account.mute!(bob, notifications: false)
        subject.call(import)
        expect(account.muting.count).to eq 2
        expect(Mute.find_by(account: account, target_account: bob).hide_notifications).to be true
      end
    end

    describe 'when some accounts are muted and overwrite is set' do
      let(:import) { Import.create(account: account, type: 'muting', data: csv, overwrite: true) }

      it 'mutes the listed accounts, including notifications' do
        account.mute!(bob, notifications: false)
        subject.call(import)
        expect(account.muting.count).to eq 2
        expect(Mute.find_by(account: account, target_account: bob).hide_notifications).to be true
      end
    end
  end

  context 'import new-style list of muted users' do
    subject { ImportService.new }

    let(:csv) { attachment_fixture('new-mute-imports.txt') }

    describe 'when no accounts are muted' do
      let(:import) { Import.create(account: account, type: 'muting', data: csv) }
      it 'mutes the listed accounts, respecting notifications' do
        subject.call(import)
        expect(account.muting.count).to eq 2
        expect(Mute.find_by(account: account, target_account: bob).hide_notifications).to be true
        expect(Mute.find_by(account: account, target_account: eve).hide_notifications).to be false
      end
    end

    describe 'when some accounts are muted and overwrite is not set' do
      let(:import) { Import.create(account: account, type: 'muting', data: csv) }

      it 'mutes the listed accounts, respecting notifications' do
        account.mute!(bob, notifications: true)
        subject.call(import)
        expect(account.muting.count).to eq 2
        expect(Mute.find_by(account: account, target_account: bob).hide_notifications).to be true
        expect(Mute.find_by(account: account, target_account: eve).hide_notifications).to be false
      end
    end

    describe 'when some accounts are muted and overwrite is set' do
      let(:import) { Import.create(account: account, type: 'muting', data: csv, overwrite: true) }

      it 'mutes the listed accounts, respecting notifications' do
        account.mute!(bob, notifications: true)
        subject.call(import)
        expect(account.muting.count).to eq 2
        expect(Mute.find_by(account: account, target_account: bob).hide_notifications).to be true
        expect(Mute.find_by(account: account, target_account: eve).hide_notifications).to be false
      end
    end
  end
end
