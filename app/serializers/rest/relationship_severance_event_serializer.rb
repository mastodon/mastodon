# frozen_string_literal: true

class REST::RelationshipSeveranceEventSerializer < ActiveModel::Serializer
  attributes :id, :type, :target_name, :created_at

  attribute :relationships_count, if: -> { current_user.present? }

  def id
    object.id.to_s
  end

  def relationships_count
    object.severed_relationships.where(local_account: current_user.account).count
  end
end
