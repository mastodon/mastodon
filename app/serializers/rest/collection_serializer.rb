# frozen_string_literal: true

class REST::CollectionSerializer < ActiveModel::Serializer
  attributes :id, :uri, :name, :description, :language, :account_id,
             :local, :sensitive, :discoverable, :item_count,
             :created_at, :updated_at

  belongs_to :tag, serializer: REST::ShallowTagSerializer

  has_many :items, serializer: REST::CollectionItemSerializer

  def id
    object.id.to_s
  end

  def description
    return object.description if object.local?
    return if object.description_html.nil?

    Sanitize.fragment(object.description_html, Sanitize::Config::MASTODON_STRICT)
  end

  def items
    object.items_for(current_user&.account)
  end

  def account_id
    object.account_id.to_s
  end
end
