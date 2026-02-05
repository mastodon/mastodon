# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DeleteCollectionService do
  subject { described_class.new }

  let!(:collection) { Fabricate(:collection) }

  describe '#call' do
    it 'destroys the collection' do
      expect { subject.call(collection) }.to change(Collection, :count).by(-1)
    end

    it 'federates a `Remove` activity', feature: :collections_federation do
      subject.call(collection)

      expect(ActivityPub::AccountRawDistributionWorker).to have_enqueued_sidekiq_job
    end
  end
end
