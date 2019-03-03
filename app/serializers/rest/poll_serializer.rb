# frozen_string_literal: true

class REST::PollSerializer < ActiveModel::Serializer
  attributes :id, :expires_at, :expired,
             :multiple, :votes_count

  has_many :dynamic_options, key: :options

  attribute :voted, if: :current_user?

  def id
    object.id.to_s
  end

  def dynamic_options
    if !object.expired? && object.hide_totals?
      object.unloaded_options
    else
      object.loaded_options
    end
  end

  def expired
    object.expired?
  end

  def voted
    object.votes.where(account: current_user.account).exists?
  end

  def current_user?
    !current_user.nil?
  end

  class OptionSerializer < ActiveModel::Serializer
    attributes :title, :votes_count
  end
end
