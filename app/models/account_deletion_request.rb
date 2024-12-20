# frozen_string_literal: true

# == Schema Information
#
# Table name: account_deletion_requests
#
#  id         :bigint(8)        not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  account_id :bigint(8)        not null
#
class AccountDeletionRequest < ApplicationRecord
  DELAY_TO_DELETION = 30.days.freeze

  belongs_to :account

  def due_at
    created_at + DELAY_TO_DELETION
  end
end
