# frozen_string_literal: true

class REST::AnnouncementSerializer < ActiveModel::Serializer
  attributes :id, :content, :starts_at, :ends_at, :all_day,
             :published_at, :updated_at

  attribute :read, if: :current_user?

  has_many :mentions
  has_many :tags, serializer: REST::StatusSerializer::TagSerializer
  has_many :emojis, serializer: REST::CustomEmojiSerializer
  has_many :reactions, serializer: REST::ReactionSerializer

  def current_user?
    !current_user.nil?
  end

  def id
    object.id.to_s
  end

  def read
    object.announcement_mutes.where(account: current_user.account).exists?
  end

  def content
    Formatter.instance.linkify(object.text)
  end

  def reactions
    object.reactions(current_user&.account)
  end

  class AccountSerializer < ActiveModel::Serializer
    attributes :id, :username, :url, :acct

    def id
      object.id.to_s
    end

    def url
      ActivityPub::TagManager.instance.url_for(object)
    end

    def acct
      object.pretty_acct
    end
  end
end
