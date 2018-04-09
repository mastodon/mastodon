# frozen_string_literal: true
# == Schema Information
#
# Table name: favourites
#
#  id         :integer          not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  account_id :integer          not null
#  status_id  :integer          not null
#

class Favourite < ApplicationRecord
  include Paginable

  update_index('statuses#status', :status) if Chewy.enabled?

  belongs_to :account, inverse_of: :favourites
  belongs_to :status,  inverse_of: :favourites, counter_cache: true

  has_one :notification, as: :activity, dependent: :destroy

  validates :status_id, uniqueness: { scope: :account_id }

  before_validation do
    self.status = status.reblog if status&.reblog?
  end
end
