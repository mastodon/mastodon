# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PublishAnnouncementReactionWorker do
  let(:worker) { described_class.new }

  describe '#perform' do
    before { Fabricate(:account, user: Fabricate(:user, current_sign_in_at: 1.hour.ago)) }

    let(:announcement) { Fabricate(:announcement) }
    let(:name) { 'name value' }

    it 'sends the announcement and name to the service when subscribed' do
      allow(redis).to receive(:exists?).and_return(true)
      allow(redis).to receive(:publish)

      worker.perform(announcement.id, name)

      expect(redis).to have_received(:publish)
    end

    it 'does not send the announcement and name to the service when not subscribed' do
      allow(redis).to receive(:exists?).and_return(false)
      allow(redis).to receive(:publish)

      worker.perform(announcement.id, name)

      expect(redis).to_not have_received(:publish)
    end

    it 'returns true for non-existent record' do
      result = worker.perform(123_123_123, name)

      expect(result).to be(true)
    end
  end
end
