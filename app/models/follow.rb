class Follow < ActiveRecord::Base
  include Streamable

  belongs_to :account
  belongs_to :target_account, class_name: 'Account'

  validates :account, :target_account, presence: true
  validates :account_id, uniqueness: { scope: :target_account_id }

  def verb
    self.destroyed? ? :unfollow : :follow
  end

  def target
    self.target_account
  end

  def object_type
    :person
  end

  def title
    self.destroyed? ? "#{self.account.acct} is no longer following #{self.target_account.acct}" : "#{self.account.acct} started following #{self.target_account.acct}"
  end
end
