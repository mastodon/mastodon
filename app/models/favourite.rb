# frozen_string_literal: true

class Favourite < ApplicationRecord
  include Paginable

  belongs_to :account, inverse_of: :favourites, required: true
  belongs_to :status,  inverse_of: :favourites, counter_cache: true, required: true

  has_one :notification, as: :activity, dependent: :destroy

  validates :status_id, uniqueness: { scope: :account_id }

  before_validation do
    self.status = status.reblog if status&.reblog?
  end
end
