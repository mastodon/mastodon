class User < ActiveRecord::Base
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :trackable, :validatable

  belongs_to :account, inverse_of: :user
  accepts_nested_attributes_for :account

  validates :account, presence: true
end
