class Favourite < ApplicationRecord
  include Streamable

  belongs_to :account, inverse_of: :favourites
  belongs_to :status,  inverse_of: :favourites

  validates :status_id, uniqueness: { scope: :account_id }

  def verb
    :favorite
  end

  def title
    "#{account.acct} favourited a status by #{status.account.acct}"
  end

  def object_type
    target.object_type
  end

  def thread
    status
  end

  def target
    thread
  end
end
