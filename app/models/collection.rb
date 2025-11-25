# frozen_string_literal: true

# == Schema Information
#
# Table name: collections
#
#  id                       :bigint(8)        not null, primary key
#  description              :text             not null
#  discoverable             :boolean          not null
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
  validate :tag_is_usable
  validate :items_do_not_exceed_limit

  def remote?
    !local?
  end

  private

  def tag_is_usable
    return if tag.blank?

    errors.add(:tag, :unusable) unless tag.usable?
  end

  def items_do_not_exceed_limit
    errors.add(:collection_items, :too_many, count: MAX_ITEMS) if collection_items.size > MAX_ITEMS
  end
end
