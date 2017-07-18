# == Schema Information
#
# Table name: favourite_tags
#
#  id         :integer          not null, primary key
#  account_id :integer          not null
#  tag_id     :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class FavouriteTag < ApplicationRecord

  belongs_to :account, required: true
  belongs_to :tag, required: true
  accepts_nested_attributes_for :tag

  validates :tag, uniqueness: { scope: :account }
end
