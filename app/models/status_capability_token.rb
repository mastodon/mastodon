# frozen_string_literal: true

# == Schema Information
#
# Table name: status_capability_tokens
#
#  id         :bigint(8)        not null, primary key
#  status_id  :bigint(8)
#  token      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class StatusCapabilityToken < ApplicationRecord
  belongs_to :status

  validates :token, presence: true

  before_validation :generate_token, on: :create

  private

  def generate_token
    self.token = Doorkeeper::OAuth::Helpers::UniqueToken.generate
  end
end
