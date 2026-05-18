# frozen_string_literal: true

class REST::ProfileSerializer < ActiveModel::Serializer
  include RoutingHelper
  include FormattingHelper

  # Please update app/javascript/api_types/profile.ts when making changes to the attributes
  attributes :id, :display_name, :note, :fields,
             :formatted_note, :formatted_fields,
             :avatar, :avatar_static, :avatar_description, :header, :header_static, :header_description,
             :locked, :bot,
             :hide_collections, :discoverable, :indexable,
             :show_media, :show_media_replies, :show_featured,
             :attribution_domains

  has_many :featured_tags, serializer: REST::FeaturedTagSerializer

  def id
    object.id.to_s
  end

  def formatted_note
    account_bio_format(object)
  end

  def fields
    object.fields.map(&:to_h)
  end

  def formatted_fields
    object.fields.map { |field| { name: field.name, value: account_field_value_format(field), verified_at: field.verified_at } }
  end

  def avatar
    object.avatar_file_name.present? ? full_asset_url(object.avatar_original_url) : nil
  end

  def avatar_static
    object.avatar_file_name.present? ? full_asset_url(object.avatar_static_url) : nil
  end

  def header
    object.header_file_name.present? ? full_asset_url(object.header_original_url) : nil
  end

  def header_static
    object.header_file_name.present? ? full_asset_url(object.header_static_url) : nil
  end
end
