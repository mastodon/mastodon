# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RevokeQuoteService do
  subject { described_class.new }

  let!(:alice) { Fabricate(:account) }
  let!(:hank) { Fabricate(:account, username: 'hank', protocol: :activitypub, domain: 'example.com', inbox_url: 'http://example.com/inbox') }

  let(:status) { Fabricate(:status, account: alice) }

  let(:quote) { Fabricate(:quote, quoted_status: status, state: :accepted) }

  before do
    hank.follow!(alice)
  end

  context 'with an accepted quote' do
    it 'revokes the quote and sends a Delete activity' do
      expect { described_class.new.call(quote) }
        .to change { quote.reload.state }.from('accepted').to('revoked')
        .and enqueue_sidekiq_job(ActivityPub::DeliveryWorker).with(/Delete/, alice.id, hank.inbox_url)
    end
  end
end
