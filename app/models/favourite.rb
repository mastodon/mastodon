class Favourite < ApplicationRecord
  include Streamable

  belongs_to :account, inverse_of: :favourites
  belongs_to :status,  inverse_of: :favourites, touch: true

  validates :status_id, uniqueness: { scope: :account_id }

  def verb
    :favorite
  end

  def title
    "#{account.acct} favourited a status by #{status.account.acct}"
  end

  delegate :object_type, to: :target

  def thread
    status
  end

  def target
    thread
  end
end
