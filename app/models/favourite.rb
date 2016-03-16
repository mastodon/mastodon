class Favourite < ActiveRecord::Base
  belongs_to :account, inverse_of: :favourites
  belongs_to :status,  inverse_of: :favourites

  has_one :stream_entry, as: :activity

  def verb
    :favorite
  end

  def title
    "#{self.account.acct} favourited a status by #{self.status.account.acct}"
  end

  def content
    title
  end

  def object_type
    target.object_type
  end

  def target
    self.status
  end

  def mentions
    []
  end

  def thread
    target
  end

  after_create do
    self.account.stream_entries.create!(activity: self)
  end
end
