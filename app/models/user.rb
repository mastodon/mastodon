class User < ActiveRecord::Base
  belongs_to :account, inverse_of: :user

  validates :account, presence: true
end
