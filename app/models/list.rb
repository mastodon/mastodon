# == Schema Information
#
# Table name: lists
#
#  id         :integer          not null, primary key
#  account_id :integer
#  title      :string           default(""), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class List < ApplicationRecord
  belongs_to :account
  has_and_belongs_to_many :accounts

  validates :title, presence: true
end
