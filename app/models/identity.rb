# frozen_string_literal: true

# == Schema Information
#
# Table name: identities
#
#  id         :bigint(8)        not null, primary key
#  provider   :string           default(""), not null
#  uid        :string           default(""), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :bigint(8)
#

class Identity < ApplicationRecord
  belongs_to :user
  validates :uid, presence: true, uniqueness: { scope: :provider }
  validates :provider, presence: true

  def self.find_for_omniauth(auth)
    find_or_create_by(uid: auth.uid, provider: auth.provider)
  end
end
