# frozen_string_literal: true

class CreateCollectionService
  def call(params, account)
    tag = params.delete(:tag)
    account_ids = params.delete(:account_ids)
    @collection = Collection.new(params.merge({ account:, local: true, tag: find_or_create_tag(tag) }))
    build_items(account_ids)

    @collection.save!
    @collection
  end

  private

  def find_or_create_tag(name)
    return nil if name.blank?

    Tag.find_or_create_by_names(name).first
  end

  def build_items(account_ids)
    return if account_ids.blank?

    account_ids.each do |account_id|
      account = Account.find(account_id)
      # TODO: validate preferences
      @collection.collection_items.build(account:)
    end
  end
end
