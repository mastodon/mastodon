# frozen_string_literal: true

# == Schema Information
#
# Table name: collections
#
#  id           :bigint(8)        not null, primary key
#  description  :text             not null
#  discoverable :boolean          not null
#  local        :boolean          not null
#  name         :string           not null
#  remote_items :integer
#  sensitive    :boolean          not null
#  uri          :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  account_id   :bigint(8)        not null
#  tag_id       :bigint(8)
#
class Collection < ApplicationRecord
  belongs_to :account
  belongs_to :tag, optional: true

  has_many :collection_items, dependent: :delete_all

  validates :name, presence: true
  validates :description, presence: true
  validates :uri, presence: true, if: :remote?
  validates :remote_items, presence: true,
                           numericality: { greater_than_or_equal: 0 },
                           if: :remote?
  validate :tag_is_usable

  def remote?
    !local?
  end

  private

  def tag_is_usable
    return if tag.blank?

    errors.add(:tag, :unusable) unless tag.usable?
  end
end
