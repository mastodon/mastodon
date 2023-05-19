# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BulkImportRowService do
  subject { described_class.new }

  let(:account)    { Fabricate(:account) }
  let(:import)     { Fabricate(:bulk_import, account: account, type: import_type) }
  let(:import_row) { Fabricate(:bulk_import_row, bulk_import: import, data: data) }

  describe '#call' do
    context 'when importing a follow' do
      let(:import_type)    { 'following' }
      let(:target_account) { Fabricate(:account) }
      let(:service_double) { instance_double(FollowService, call: nil) }
      let(:data) do
        { 'acct' => target_account.acct }
      end

      before do
        allow(FollowService).to receive(:new).and_return(service_double)
      end

      it 'calls FollowService with the expected arguments and returns true' do
        expect(subject.call(import_row)).to be true

        expect(service_double).to have_received(:call).with(account, target_account, { reblogs: nil, notify: nil, languages: nil })
      end
    end

    context 'when importing a block' do
      let(:import_type)    { 'blocking' }
      let(:target_account) { Fabricate(:account) }
      let(:service_double) { instance_double(BlockService, call: nil) }
      let(:data) do
        { 'acct' => target_account.acct }
      end

      before do
        allow(BlockService).to receive(:new).and_return(service_double)
      end

      it 'calls BlockService with the expected arguments and returns true' do
        expect(subject.call(import_row)).to be true

        expect(service_double).to have_received(:call).with(account, target_account)
      end
    end

    context 'when importing a mute' do
      let(:import_type)    { 'muting' }
      let(:target_account) { Fabricate(:account) }
      let(:service_double) { instance_double(MuteService, call: nil) }
      let(:data) do
        { 'acct' => target_account.acct }
      end

      before do
        allow(MuteService).to receive(:new).and_return(service_double)
      end

      it 'calls MuteService with the expected arguments and returns true' do
        expect(subject.call(import_row)).to be true

        expect(service_double).to have_received(:call).with(account, target_account, { notifications: nil })
      end
    end

    context 'when importing a bookmark' do
      let(:import_type) { 'bookmarks' }
      let(:data) do
        { 'uri' => ActivityPub::TagManager.instance.uri_for(target_status) }
      end

      context 'when the status is public' do
        let(:target_status) { Fabricate(:status) }

        it 'bookmarks the status and returns true' do
          expect(subject.call(import_row)).to be true
          expect(account.bookmarked?(target_status)).to be true
        end
      end

      context 'when the status is not accessible to the user' do
        let(:target_status) { Fabricate(:status, visibility: :direct) }

        it 'does not bookmark the status and returns false' do
          expect(subject.call(import_row)).to be false
          expect(account.bookmarked?(target_status)).to be false
        end
      end
    end
  end
end
