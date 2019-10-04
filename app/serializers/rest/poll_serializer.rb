# frozen_string_literal: true

class REST::PollSerializer < ActiveModel::Serializer
  attributes :id, :expires_at, :expired,
             :multiple, :votes_count, :voters_count

  has_many :loaded_options, key: :options
  has_many :emojis, serializer: REST::CustomEmojiSerializer

  attribute :voted, if: :current_user?
  attribute :own_votes, if: :current_user?

  def id
    object.id.to_s
  end

  def expired
    object.expired?
  end

  def voted
    object.voted?(current_user.account)
  end

  def own_votes
    object.own_votes(current_user.account)
  end

  def current_user?
    !current_user.nil?
  end

  class OptionSerializer < ActiveModel::Serializer
    attributes :title, :votes_count
  end

  include Friends::ProfileEmoji::SerializerExtension
end
