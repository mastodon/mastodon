class Follow < ActiveRecord::Base
  belongs_to :account
  belongs_to :target_account, class_name: 'Account'

  has_one :stream_entry, as: :activity

  validates :account, :target_account, presence: true
  validates :account_id, uniqueness: { scope: :target_account_id }

  def verb
    :follow
  end

  def target
    self.target_account
  end

  def object_type
    target.object_type
  end

  def content
    "#{self.account.acct} started following #{self.target_account.acct}"
  end

  def title
    content
  end

  def mentions
    []
  end

  after_create do
    self.account.stream_entries.create!(activity: self)
  end
end
