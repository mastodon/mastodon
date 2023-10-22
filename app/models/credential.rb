# == Schema Information
#
# Table name: credentials
#
#  id          :bigint           not null, primary key
#  user_id     :bigint           not null
#  external_id :string
#  public_key  :string
#  sign_count  :bigint
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
class Credential < ApplicationRecord
  validates :external_id, :public_key, :sign_count, presence: true
  validates :external_id, uniqueness: true
  validates :sign_count,
            numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: (2**32) - 1 }

  belongs_to :user
end

