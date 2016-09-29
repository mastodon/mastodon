class Follow < ApplicationRecord
  include Streamable

  belongs_to :account
  belongs_to :target_account, class_name: 'Account'

  validates :account, :target_account, presence: true
  validates :account_id, uniqueness: { scope: :target_account_id }

  def verb
    destroyed? ? :unfollow : :follow
  end

  def target
    target_account
  end

  def object_type
    :person
  end

  def title
    destroyed? ? "#{account.acct} is no longer following #{target_account.acct}" : "#{account.acct} started following #{target_account.acct}"
  end
end
