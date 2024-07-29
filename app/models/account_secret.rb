# frozen_string_literal: true

# == Schema Information
#
# Table name: account_secrets
#
#  id          :bigint(8)        not null, primary key
#  private_key :text
#  account_id  :bigint(8)        not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
class AccountSecret < ApplicationRecord
  belongs_to :account

  encrypts :private_key
end
