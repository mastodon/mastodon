# frozen_string_literal: true

class CreateCollectionService
  def call(params, account)
    account_ids = params.delete(:account_ids)
    @collection = Collection.new(params.merge({ account:, local: true }))
    build_items(account_ids)

    @collection.save!
    @collection
  end

  private

  def build_items(account_ids)
    return if account_ids.blank?

    account_ids.each do |account_id|
      account = Account.find(account_id)
      raise Mastodon::NotPermittedError, I18n.t('accounts.errors.cannot_be_added_to_collections') unless AccountPolicy.new(@collection.account, account).feature?

      @collection.collection_items.build(account:)
    end
  end
end
