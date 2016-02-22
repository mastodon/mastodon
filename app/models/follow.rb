class Follow < ActiveRecord::Base
  belongs_to :account
  belongs_to :target_account, class_name: 'Account'

  validates :account, :target_account, presence: true

  def verb
    :follow
  end

  def object_type
    :person
  end

  def target
    self.target_account
  end

  def content
    "#{self.account.acct} started following #{self.target_account.acct}"
  end

  def title
    content
  end

  after_create do
    self.account.stream_entries.create!(activity: self)
  end
end
