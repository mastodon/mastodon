# frozen_string_literal: true

class REST::CollectionSerializer < ActiveModel::Serializer
  attributes :id, :uri, :name, :description, :language, :account_id,
             :local, :sensitive, :discoverable, :url, :item_count,
             :created_at, :updated_at

  belongs_to :tag, serializer: REST::ShallowTagSerializer

  has_many :items, serializer: REST::CollectionItemSerializer

  def id
    object.id.to_s
  end

  def uri
    ActivityPub::TagManager.instance.uri_for(object)
  end

  def url
    ActivityPub::TagManager.instance.url_for(object)
  end

  def description
    return object.description if object.local?
    return if object.description_html.nil?

    Sanitize.fragment(object.description_html, Sanitize::Config::MASTODON_STRICT)
  end

  def items
    @items ||= object.items_for(current_user&.account)
  end

  def item_count
    items.size
  end

  def account_id
    object.account_id.to_s
  end
end
