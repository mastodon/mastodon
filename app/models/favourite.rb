class Favourite < ApplicationRecord
  include Streamable

  belongs_to :account, inverse_of: :favourites
  belongs_to :status,  inverse_of: :favourites

  def verb
    :favorite
  end

  def title
    "#{self.account.acct} favourited a status by #{self.status.account.acct}"
  end

  def object_type
    target.object_type
  end

  def thread
    self.status
  end

  def target
    thread
  end
end
