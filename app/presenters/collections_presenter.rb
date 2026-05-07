# frozen_string_literal: true

class CollectionsPresenter < ActiveModelSerializers::Model
  attributes :collections

  def accounts
    owners = collections.map(&:account)
    top_accounts = collections.flat_map { |c| c.top_items.map(&:account) }
    (owners + top_accounts).uniq
  end
end
