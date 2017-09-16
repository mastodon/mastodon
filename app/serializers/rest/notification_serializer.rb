# frozen_string_literal: true

class REST::NotificationSerializer < ActiveModel::Serializer
  include RoutingHelper

  attributes :id, :type, :created_at
  attribute :avatar, if: :profile_type?
  attribute :avatar_static, if: :profile_type?
  attribute :display_name, if: :profile_type?

  belongs_to :from_account, key: :account, serializer: REST::AccountSerializer
  belongs_to :target_status, key: :status, if: :status_type?, serializer: REST::StatusSerializer

  def id
    object.id.to_s
  end

  def status_type?
    [:favourite, :reblog, :mention].include?(object.type)
  end

  def profile_type?
    object.type == :profile_change
  end

  def display_name
    object.activity.display_name
  end

  def avatar
    full_asset_url(object.activity.avatar_original_url)
  end

  def avatar_static
    full_asset_url(object.activity.avatar_static_url)
  end
end
