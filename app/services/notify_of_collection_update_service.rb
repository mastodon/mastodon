# frozen_string_literal: true

class NotifyOfCollectionUpdateService
  def call(collection)
    return unless significantly_changed?(collection)

    collection.collection_items.includes(:account).references(:account).merge(Account.local).accepted.find_each do |collection_item|
      LocalNotificationWorker.perform_async(collection_item.account_id, collection.id, collection.class.name, 'collection_update')
    end
  end

  private

  def significantly_changed?(collection)
    # If the collection is brand new, we don't need to look at its members
    return false if collection.previously_new_record?

    # Only notify of change to description or name
    %i(description description_html name).any? { |attr| collection.attribute_previously_changed?(attr) }
  end
end
