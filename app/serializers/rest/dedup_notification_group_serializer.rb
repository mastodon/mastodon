# frozen_string_literal: true

class REST::DedupNotificationGroupSerializer < ActiveModel::Serializer
  class PartialAccountSerializer < REST::AccountSerializer
    # This is a hack to reset ActiveModel::Serializer internals and only expose the attributes
    # we care about.
    self._attributes_data = {}
    self._reflections = []
    self._links = []

    attributes :id, :acct, :locked, :bot, :url, :avatar, :avatar_static
  end

  has_many :accounts, serializer: REST::AccountSerializer
  has_many :partial_accounts, serializer: PartialAccountSerializer, if: :return_partial_accounts?
  has_many :statuses, serializer: REST::StatusSerializer
  has_many :notification_groups, serializer: REST::NotificationGroupSerializer

  def return_partial_accounts?
    instance_options[:expand_accounts] == 'partial_avatars'
  end
end
