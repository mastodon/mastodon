# frozen_string_literal: true

class NotifyOfCollectionUpdateService
  def call(collection)
    return if collection.previously_new_record? || %i(description description_html name).none? { |attr| collection.attribute_previously_changed?(attr) }

    collection.collection_items.includes(:account).references(:account).merge(Account.local).accepted.find_each do |collection_item|
      LocalNotificationWorker.perform_async(collection_item.account_id, collection.id, collection.class.name, 'collection_update')
    end
  end
end
