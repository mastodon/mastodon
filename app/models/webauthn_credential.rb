# frozen_string_literal: true

# == Schema Information
#
# Table name: webauthn_credentials
#
#  id          :bigint(8)        not null, primary key
#  external_id :string           not null
#  public_key  :string           not null
#  nickname    :string           not null
#  sign_count  :bigint(8)        default(0), not null
#  user_id     :bigint(8)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class WebauthnCredential < ApplicationRecord
  SIGN_COUNT_LIMIT = (2**63)

  validates :external_id, :public_key, :nickname, :sign_count, presence: true
  validates :external_id, uniqueness: true
  validates :nickname, uniqueness: { scope: :user_id }
  validates :sign_count,
            numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: SIGN_COUNT_LIMIT - 1 }
end
