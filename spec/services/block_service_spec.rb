# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BlockService do
  subject { described_class.new }

  let(:sender) { Fabricate(:account, username: 'alice') }

  describe 'local' do
    let(:bob) { Fabricate(:account, username: 'bob') }

    before do
      NotificationPermission.create!(account: sender, from_account: bob)
    end

    it 'creates a blocking relation and removes notification permissions' do
      expect { subject.call(sender, bob) }
        .to change { sender.blocking?(bob) }.from(false).to(true)
        .and change { NotificationPermission.exists?(account: sender, from_account: bob) }.from(true).to(false)
    end

    context 'when the block affects collections' do
      context 'when the sender features the target in a collection' do
        let(:collection) { Fabricate(:collection, account: sender) }
        let!(:collection_item) { Fabricate(:collection_item, collection:, account: bob) }

        it 'removes the affected item from the collection' do
          expect { subject.call(sender, bob) }.to change(CollectionItem, :count).by(-1)
          expect { collection_item.reload }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end

      context 'when the sender is featured by the target in a collection' do
        let(:collection) { Fabricate(:collection, account: bob) }
        let!(:collection_item) { Fabricate(:collection_item, collection:, account: sender) }

        it 'revokes the inclusion in the collection' do
          subject.call(sender, bob)
          expect(collection_item.reload).to be_revoked
        end
      end
    end
  end

  describe 'remote ActivityPub' do
    let(:bob) { Fabricate(:account, username: 'bob', protocol: :activitypub, domain: 'example.com', inbox_url: 'http://example.com/inbox') }

    before do
      stub_request(:post, 'http://example.com/inbox').to_return(status: 200)
    end

    it 'creates a blocking relation and send block activity', :inline_jobs do
      subject.call(sender, bob)

      expect(sender)
        .to be_blocking(bob)

      expect(a_request(:post, 'http://example.com/inbox'))
        .to have_been_made.once
    end
  end
end
