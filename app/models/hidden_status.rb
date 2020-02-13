# frozen_string_literal: true
# == Schema Information
#
# Table name: hidden_statuses
#
#  id         :bigint(8)        not null, primary key
#  account_id :bigint(8)        not null
#  status_id  :bigint(8)        not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class HiddenStatus < ApplicationRecord
  update_index('statuses#status', :status) if Chewy.enabled?

  belongs_to :account, inverse_of: :hidden_statuses
  belongs_to :status,  inverse_of: :hidden_statuses

  validates :status_id, uniqueness: { scope: :account_id }
end
