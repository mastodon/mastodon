class User < ActiveRecord::Base
  belongs_to :account, inverse_of: :user

  validates :account, presence: true

  def timeline
    StreamEntry.where(account_id: self.account.following, activity_type: 'Status').order('id desc')
  end
end
