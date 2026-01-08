# frozen_string_literal: true

class AddAccountToCollectionService
  def call(collection, account)
    raise ArgumentError unless collection.local?

    @collection = collection
    @account = account

    raise Mastodon::NotPermittedError, I18n.t('accounts.errors.cannot_be_added_to_collections') unless AccountPolicy.new(@collection.account, @account).feature?

    create_collection_item
  end

  private

  def create_collection_item
    @collection.collection_items.create!(
      account: @account,
      state: :accepted
    )
  end
end
