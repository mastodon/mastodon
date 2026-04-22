# frozen_string_literal: true

# == Schema Information
#
# Table name: collections
#
#  id                       :bigint(8)        not null, primary key
#  description              :text
#  description_html         :text
#  discoverable             :boolean          not null
#  item_count               :integer          default(0), not null
#  language                 :string
#  local                    :boolean          not null
#  name                     :string           not null
#  original_number_of_items :integer
#  sensitive                :boolean          not null
#  uri                      :string
#  url                      :string
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  account_id               :bigint(8)        not null
#  tag_id                   :bigint(8)
#
class Collection < ApplicationRecord
  MAX_ITEMS = 25
  NAME_LENGTH_HARD_LIMIT = 256
  DESCRIPTION_LENGTH_HARD_LIMIT = 2048

  belongs_to :account
  belongs_to :tag, optional: true

  has_many :collection_items, dependent: :delete_all
  has_many :accepted_collection_items, -> { accepted }, class_name: 'CollectionItem', inverse_of: :collection # rubocop:disable Rails/HasManyOrHasOneDependent
  has_many :collection_reports, dependent: :delete_all

  validates :name, presence: true
  validates :name, length: { maximum: 40 }, if: :local?
  validates :name, length: { maximum: NAME_LENGTH_HARD_LIMIT }, if: :remote?
  validates :description,
            length: { maximum: 100 },
            if: :local?
  validates :description_html,
            length: { maximum: DESCRIPTION_LENGTH_HARD_LIMIT },
            if: :remote?
  validates :local, inclusion: [true, false]
  validates :sensitive, inclusion: [true, false]
  validates :discoverable, inclusion: [true, false]
  validates :uri, presence: true, if: :remote?
  validates :original_number_of_items,
            presence: true,
            numericality: { greater_than_or_equal: 0 },
            if: :remote?
  validates :language, language: { if: :local?, allow_nil: true }
  validate :tag_is_usable
  validate :items_do_not_exceed_limit

  scope :with_items, -> { includes(:collection_items).merge(CollectionItem.with_accounts) }
  scope :with_tag, -> { includes(:tag) }
  scope :discoverable, -> { where(discoverable: true) }
  scope :local, -> { where(local: true) }

  def remote?
    !local?
  end

  def items_for(account = nil)
    result = collection_items.with_accounts
    result = account == self.account ? result.pending_or_accepted : result.accepted
    result = result.not_blocked_by(account) unless account.nil?
    result
  end

  def tag_name
    tag&.formatted_name
  end

  def tag_name=(new_name)
    self.tag = Tag.find_or_create_by_names(new_name).first
  end

  def object_type
    :featured_collection
  end

  def to_log_human_identifier
    account.acct
  end

  def to_log_permalink
    ActivityPub::TagManager.instance.uri_for(self)
  end

  private

  def tag_is_usable
    return if tag.blank?

    errors.add(:tag_name, :unusable) unless tag.usable?
  end

  def pending_or_accepted_items
    collection_items.select { |i| i.accepted? || i.pending? }
  end

  def items_do_not_exceed_limit
    errors.add(:collection_items, :too_many, count: MAX_ITEMS) if pending_or_accepted_items.size > MAX_ITEMS
  end
end
