# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ActivityPub::QuoteRequestWorker do
  subject { described_class.new }

  let(:quoted_account) { Fabricate(:account, inbox_url: 'http://example.com', domain: 'example.com') }
  let(:quoted_status) { Fabricate(:status, account: quoted_account) }
  let(:status) { Fabricate(:status, text: 'foo') }
  let(:quote) { Fabricate(:quote, status: status, quoted_status: quoted_status, activity_uri: 'TODO') } # TODO: activity URI

  describe '#perform' do
    it 'sends the expected QuoteRequest activity' do
      subject.perform(quote.id)

      expect(ActivityPub::DeliveryWorker)
        .to have_enqueued_sidekiq_job(match_object_shape, quote.account_id, 'http://example.com', {})
    end

    def match_object_shape
      match_json_values(
        type: 'QuoteRequest',
        actor: ActivityPub::TagManager.instance.uri_for(quote.account),
        object: ActivityPub::TagManager.instance.uri_for(quoted_status),
        instrument: a_hash_including(
          id: ActivityPub::TagManager.instance.uri_for(status)
        )
      )
    end
  end
end
