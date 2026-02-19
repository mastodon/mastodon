# frozen_string_literal: true

# == Schema Information
#
# Table name: collections
#
#  id                       :bigint(8)        not null, primary key
#  description              :text             not null
#  discoverable             :boolean          not null
#  item_count               :integer          default(0), not null
#  language                 :string
#  local                    :boolean          not null
#  name                     :string           not null
#  original_number_of_items :integer
#  sensitive                :boolean          not null
#  uri                      :string
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  account_id               :bigint(8)        not null
#  tag_id                   :bigint(8)
#
class Collection < ApplicationRecord
  MAX_ITEMS = 25

  belongs_to :account
  belongs_to :tag, optional: true

  has_many :collection_items, dependent: :delete_all
  has_many :accepted_collection_items, -> { accepted }, class_name: 'CollectionItem', inverse_of: :collection # rubocop:disable Rails/HasManyOrHasOneDependent
  has_many :collection_reports, dependent: :delete_all

  validates :name, presence: true
  validates :description, presence: true
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

  def remote?
    !local?
  end

  def items_for(account = nil)
    result = collection_items.with_accounts
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

  private

  def tag_is_usable
    return if tag.blank?

    errors.add(:tag_name, :unusable) unless tag.usable?
  end

  def items_do_not_exceed_limit
    errors.add(:collection_items, :too_many, count: MAX_ITEMS) if collection_items.size > MAX_ITEMS
  end
end
