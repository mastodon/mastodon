# == Schema Information
#
# Table name: favourite_tags
#
#  id         :integer          not null, primary key
#  account_id :integer          not null
#  tag_id     :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  visibility :integer          default("public"), not null
#

class FavouriteTag < ApplicationRecord

  enum visibility: [:public, :unlisted, :private, :direct], _suffix: :visibility

  belongs_to :account, required: true
  belongs_to :tag, required: true
  accepts_nested_attributes_for :tag

  validates :tag, uniqueness: { scope: :account }
  validates :visibility, presence: true

  delegate :name, to: :tag

  def to_json_for_api
    {
      id: self.id,
      name: self.name,
      visibility: self.visibility,
    }
  end
end
