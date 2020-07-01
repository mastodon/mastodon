# frozen_string_literal: true

class ActivityPub::ActorSerializer < ActivityPub::Serializer
  include RoutingHelper

  context :security

  context_extensions :manually_approves_followers, :featured, :also_known_as,
                     :moved_to, :property_value, :identity_proof,
                     :discoverable

  attributes :id, :type, :following, :followers,
             :inbox, :outbox, :featured,
             :preferred_username, :name, :summary,
             :url, :manually_approves_followers,
             :discoverable

  has_one :public_key, serializer: ActivityPub::PublicKeySerializer

  has_many :virtual_tags, key: :tag
  has_many :virtual_attachments, key: :attachment

  attribute :moved_to, if: :moved?
  attribute :also_known_as, if: :also_known_as?

  class EndpointsSerializer < ActivityPub::Serializer
    include RoutingHelper

    attributes :shared_inbox

    def shared_inbox
      inbox_url
    end
  end

  has_one :endpoints, serializer: EndpointsSerializer

  has_one :icon,  serializer: ActivityPub::ImageSerializer, if: :avatar_exists?
  has_one :image, serializer: ActivityPub::ImageSerializer, if: :header_exists?

  delegate :moved?, to: :object

  def id
    object.instance_actor? ? instance_actor_url : account_url(object)
  end

  def type
    if object.instance_actor?
      'Application'
    elsif object.bot?
      'Service'
    elsif object.group?
      'Group'
    else
      'Person'
    end
  end

  def following
    account_following_index_url(object)
  end

  def followers
    account_followers_url(object)
  end

  def inbox
    object.instance_actor? ? instance_actor_inbox_url : account_inbox_url(object)
  end

  def outbox
    account_outbox_url(object)
  end

  def featured
    account_collection_url(object, :featured)
  end

  def endpoints
    object
  end

  def preferred_username
    object.username
  end

  def name
    object.display_name
  end

  def summary
    Formatter.instance.simplified_format(object)
  end

  def icon
    object.avatar
  end

  def image
    object.header
  end

  def public_key
    object
  end

  def url
    object.instance_actor? ? about_more_url(instance_actor: true) : short_account_url(object)
  end

  def avatar_exists?
    object.avatar?
  end

  def header_exists?
    object.header?
  end

  def manually_approves_followers
    object.locked
  end

  def virtual_tags
    object.emojis + object.tags
  end

  def virtual_attachments
    object.fields + object.identity_proofs.active
  end

  def moved_to
    ActivityPub::TagManager.instance.uri_for(object.moved_to_account)
  end

  def also_known_as?
    !object.also_known_as.empty?
  end

  class CustomEmojiSerializer < ActivityPub::EmojiSerializer
  end

  class TagSerializer < ActivityPub::Serializer
    context_extensions :hashtag

    include RoutingHelper

    attributes :type, :href, :name

    def type
      'Hashtag'
    end

    def href
      explore_hashtag_url(object)
    end

    def name
      "##{object.name}"
    end
  end

  class Account::FieldSerializer < ActivityPub::Serializer
    attributes :type, :name, :value

    def type
      'PropertyValue'
    end

    def value
      Formatter.instance.format_field(object.account, object.value)
    end
  end

  class AccountIdentityProofSerializer < ActivityPub::Serializer
    attributes :type, :name, :signature_algorithm, :signature_value

    def type
      'IdentityProof'
    end

    def name
      object.provider_username
    end

    def signature_algorithm
      object.provider
    end

    def signature_value
      object.token
    end
  end
end
