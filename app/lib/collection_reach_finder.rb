# frozen_string_literal: true

class CollectionReachFinder < AccountReachFinder
  def initialize(collection)
    @collection = collection
    super(@collection.account)
  end

  def inboxes
    (super + collection_member_inboxes).uniq
  end

  private

  def collection_member_inboxes
    @collection.accounts.inboxes
  end
end
