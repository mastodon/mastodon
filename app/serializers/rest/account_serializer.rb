# frozen_string_literal: true

class REST::AccountSerializer < ActiveModel::Serializer
  include RoutingHelper

  attributes :id, :username, :acct, :display_name, :locked, :bot, :discoverable, :group, :created_at,
             :note, :url, :avatar, :avatar_static, :header, :header_static,
             :followers_count, :following_count, :statuses_count, :last_status_at

  has_one :moved_to_account, key: :moved, serializer: REST::AccountSerializer, if: :moved_and_not_nested?
  has_many :emojis, serializer: REST::CustomEmojiSerializer

  class FieldSerializer < ActiveModel::Serializer
    attributes :name, :value, :verified_at

    def value
      Formatter.instance.format_field(object.account, object.value)
    end
  end

  has_many :fields

  def id
    object.id.to_s
  end

  def acct
    object.pretty_acct
  end

  def note
    Formatter.instance.simplified_format(object)
  end

  def url
    ActivityPub::TagManager.instance.url_for(object)
  end

  def avatar
    full_asset_url(object.avatar_original_url)
  end

  def avatar_static
    full_asset_url(object.avatar_static_url)
  end

  def header
    full_asset_url(object.header_original_url)
  end

  def header_static
    full_asset_url(object.header_static_url)
  end

  def moved_and_not_nested?
    object.moved? && object.moved_to_account.moved_to_account_id.nil?
  end

  def followers_count
    (Setting.hide_followers_count || object.user&.setting_hide_followers_count) ? -1 : object.followers_count
  end
end
