# frozen_string_literal: true

class CreateCollectionService
  def call(params, account)
    @account = account
    @accounts_to_add = Account.find(params.delete(:account_ids) || [])
    @collection = Collection.new(params.merge({ account:, local: true }))
    build_items

    @collection.save!

    distribute_add_activity if Mastodon::Feature.collections_federation_enabled?

    @collection
  end

  private

  def distribute_add_activity
    ActivityPub::AccountRawDistributionWorker.perform_async(activity_json, @account.id)
  end

  def build_items
    return if @accounts_to_add.empty?

    @account.preload_relations!(@accounts_to_add.map(&:id))
    @accounts_to_add.each do |account_to_add|
      raise Mastodon::NotPermittedError, I18n.t('accounts.errors.cannot_be_added_to_collections') unless AccountPolicy.new(@account, account_to_add).feature?

      @collection.collection_items.build(account: account_to_add, state: :accepted)
    end
  end

  def activity_json
    ActiveModelSerializers::SerializableResource.new(@collection, serializer: ActivityPub::AddFeaturedCollectionSerializer, adapter: ActivityPub::Adapter).to_json
  end
end
