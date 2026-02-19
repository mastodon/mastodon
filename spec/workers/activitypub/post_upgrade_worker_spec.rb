# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ActivityPub::PostUpgradeWorker do
  let(:worker) { described_class.new }

  describe '#perform' do
    let(:domain) { 'host.example' }

    it 'updates relevant values' do
      account = Fabricate(:account, domain: domain, last_webfingered_at: 1.day.ago, protocol: :ostatus)
      worker.perform(domain)

      expect(account.reload.last_webfingered_at).to be_nil
    end
  end
end
