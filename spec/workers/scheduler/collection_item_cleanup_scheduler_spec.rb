# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Scheduler::CollectionItemCleanupScheduler do
  let(:worker) { described_class.new }

  describe '#perform' do
    let!(:old_rejected_item) { Fabricate(:collection_item, state: :rejected, updated_at: 25.hours.ago) }
    let!(:old_revoked_item) { Fabricate(:collection_item, state: :revoked, updated_at: 26.hours.ago) }
    let!(:new_revoked_item) { Fabricate(:collection_item, state: :revoked, updated_at: 2.hours.ago) }
    let!(:accepted_item) { Fabricate(:collection_item, state: :accepted, updated_at: 30.hours.ago) }

    it 'deletes the rejected and revoked items older than 24 hours' do
      expect { subject.perform }.to change(CollectionItem, :count).by(-2)

      expect { old_rejected_item.reload }.to raise_error(ActiveRecord::RecordNotFound)
      expect { old_revoked_item.reload }.to raise_error(ActiveRecord::RecordNotFound)
      expect { new_revoked_item.reload }.to_not raise_error
      expect { accepted_item.reload }.to_not raise_error
    end
  end
end
