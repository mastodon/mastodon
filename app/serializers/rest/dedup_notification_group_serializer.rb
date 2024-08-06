# frozen_string_literal: true

class REST::DedupNotificationGroupSerializer < ActiveModel::Serializer
  class PartialAccountSerializer < ActiveModel::Serializer
    include RoutingHelper

    attributes :id, :acct, :locked, :bot, :url, :avatar, :avatar_static

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
      ActivityPub::TagManager.instance.url_for(object)
    end

    def avatar
      full_asset_url(object.unavailable? ? object.avatar.default_url : object.avatar_original_url)
    end

    def avatar_static
      full_asset_url(object.unavailable? ? object.avatar.default_url : object.avatar_static_url)
    end
  end

  has_many :accounts, serializer: REST::AccountSerializer
  has_many :partial_accounts, serializer: PartialAccountSerializer, if: :return_partial_accounts?
  has_many :statuses, serializer: REST::StatusSerializer
  has_many :notification_groups, serializer: REST::NotificationGroupSerializer

  def return_partial_accounts?
    instance_options[:expand_accounts] == 'partial_avatars'
  end
end
