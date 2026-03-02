# frozen_string_literal: true

class REST::AccountSerializer < ActiveModel::Serializer
  include RoutingHelper
  include FormattingHelper

  # Please update `app/javascript/mastodon/api_types/accounts.ts` when making changes to the attributes

  attributes :id, :username, :acct, :display_name, :locked, :bot, :discoverable, :indexable, :group, :created_at,
             :note, :url, :uri, :avatar, :avatar_static, :avatar_description, :header, :header_static, :header_description,
             :followers_count, :following_count, :statuses_count, :last_status_at, :hide_collections,
             :show_media, :show_media_replies, :show_featured

  has_one :moved_to_account, key: :moved, serializer: REST::AccountSerializer, if: :moved_and_not_nested?

  has_many :emojis, serializer: REST::CustomEmojiSerializer

  attribute :suspended, if: :suspended?
  attribute :silenced, key: :limited, if: :silenced?
  attribute :noindex, if: :local?

  attribute :memorial, if: :memorial?

  attribute :feature_approval, if: -> { Mastodon::Feature.collections_enabled? }

  class AccountDecorator < SimpleDelegator
    def self.model_name
      Account.model_name
    end

    def moved?
      false
    end
  end

  class RoleSerializer < ActiveModel::Serializer
    attributes :id, :name, :color

    def id
      object.id.to_s
    end
  end

  has_many :roles, serializer: RoleSerializer, if: :local?

  class FieldSerializer < ActiveModel::Serializer
    include FormattingHelper

    attributes :name, :value, :verified_at

    def value
      account_field_value_format(object)
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
    object.unavailable? ? '' : account_bio_format(object)
  end

  def url
    ActivityPub::TagManager.instance.url_for(object) || ActivityPub::TagManager.instance.uri_for(object)
  end

  def uri
    ActivityPub::TagManager.instance.uri_for(object)
  end

  def avatar
    full_asset_url(object.unavailable? ? object.avatar.default_url : object.avatar_original_url)
  end

  def avatar_static
    full_asset_url(object.unavailable? ? object.avatar.default_url : object.avatar_static_url)
  end

  def avatar_description
    object.unavailable? ? '' : object.avatar_description
  end

  def header
    full_asset_url(object.unavailable? ? object.header.default_url : object.header_original_url)
  end

  def header_static
    full_asset_url(object.unavailable? ? object.header.default_url : object.header_static_url)
  end

  def header_description
    object.unavailable? ? '' : object.header_description
  end

  def created_at
    object.created_at.midnight.as_json
  end

  def last_status_at
    object.last_status_at&.to_date&.iso8601
  end

  def display_name
    object.unavailable? ? '' : object.display_name
  end

  def locked
    object.unavailable? ? false : object.locked
  end

  def bot
    object.unavailable? ? false : object.bot
  end

  def discoverable
    object.unavailable? ? false : object.discoverable
  end

  def indexable
    object.unavailable? ? false : object.indexable
  end

  def moved_to_account
    object.unavailable? ? nil : AccountDecorator.new(object.moved_to_account)
  end

  def emojis
    object.unavailable? ? [] : object.emojis
  end

  def fields
    object.unavailable? ? [] : object.fields
  end

  def suspended
    object.unavailable?
  end

  def silenced
    object.silenced?
  end

  def memorial
    object.memorial?
  end

  def roles
    if object.unavailable? || object.user.nil?
      []
    else
      [object.user.role].compact.filter(&:highlighted?)
    end
  end

  def noindex
    object.user_prefers_noindex?
  end

  delegate :suspended?, :silenced?, :local?, :memorial?, to: :object

  def moved_and_not_nested?
    object.moved?
  end

  def feature_approval
    {
      automatic: object.feature_policy_as_keys(:automatic),
      manual: object.feature_policy_as_keys(:manual),
      current_user: object.feature_policy_for_account(current_user&.account),
    }
  end
end
