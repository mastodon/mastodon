# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Webhooks::DeliveryWorker do
  let(:worker) { described_class.new }

  describe '#perform' do
    let(:webhook) { Fabricate(:webhook) }

    it 'reprocesses and updates the webhook' do
      stub_request(:post, webhook.url).to_return(status: 200, body: '')

      worker.perform(webhook.id, 'body')

      expect(a_request(:post, webhook.url)).to have_been_made.at_least_once
    end

    it 'returns true for non-existent record' do
      result = worker.perform(123_123_123, '')

      expect(result).to be(true)
    end
  end
end
