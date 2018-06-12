# == Schema Information
#
# Table name: favourite_tags
#
#  id         :bigint(8)        not null, primary key
#  account_id :bigint(8)        not null
#  tag_id     :bigint(8)        not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  visibility :integer          default("public"), not null
#  order      :integer          default(0), not null
#

class FavouriteTag < ApplicationRecord

  enum visibility: [:public, :unlisted, :private, :direct], _suffix: :visibility

  belongs_to :account, required: true
  belongs_to :tag, required: true
  accepts_nested_attributes_for :tag

  validates :tag, uniqueness: { scope: :account }
  validates :visibility, presence: true
  validates :order, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  scope :with_order, -> { order(order: :desc, id: :asc) }

  delegate :name, to: :tag

  def to_json_for_api
    {
      id: self.id,
      name: self.name,
      visibility: self.visibility,
    }
  end
end
