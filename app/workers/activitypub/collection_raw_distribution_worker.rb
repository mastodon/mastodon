# frozen_string_literal: true

class ActivityPub::CollectionRawDistributionWorker < ActivityPub::RawDistributionWorker
  def perform(json, collection_id, exclude_inboxes = [])
    @collection = Collection.find(collection_id)

    super(json, @collection.account_id, exclude_inboxes)
  end

  private

  def inboxes
    @inboxes ||= CollectionReachFinder.new(@collection).inboxes
  end
end
