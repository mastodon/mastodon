# frozen_string_literal: true

class ActivityPub::ActivitySerializer < ActivityPub::Serializer
  def self.serializer_for(model, options)
    case model.class.name
    when 'Status'
      ActivityPub::NoteSerializer
    when 'DeliverToDeviceService::EncryptedMessage'
      ActivityPub::EncryptedMessageSerializer
    else
      super
    end
  end

  class SynchronizationItemSerializer < ActivityPub::Serializer
    include RoutingHelper

    context :security
    context_extensions :collection_synchronization

    class DigestSerializer < ActivityPub::Serializer
      attributes :type, :digest_algorithm, :digest_value

      def type
        'Digest'
      end

      def digest_algorithm
        'http://www.w3.org/2001/04/xmlenc#sha256'
      end

      def digest_value
        object
      end
    end

    attributes :type, :partial_collection, :domain
    has_one :virtual_object, key: :object
    has_one :digest, serializer: DigestSerializer

    def type
      'SynchronizationItem'
    end

    def virtual_object
      account_followers_url(object.account)
    end

    def partial_collection
      account_followers_synchronization_url(object.account)
    end
  end

  attributes :id, :type, :actor, :published, :to, :cc
  has_many :collection_synchronization, serializer: SynchronizationItemSerializer, if: :collection_synchronization?

  has_one :virtual_object, key: :object

  def published
    object.published.iso8601
  end

  def collection_synchronization?
    object.collection_synchronization.present?
  end
end
