# frozen_string_literal: true

# == Schema Information
#
# Table name: invites
#
#  id         :bigint(8)        not null, primary key
#  user_id    :bigint(8)        not null
#  code       :string           default(""), not null
#  expires_at :datetime
#  max_uses   :integer
#  uses       :integer          default(0), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  autofollow :boolean          default(FALSE), not null
#  comment    :text
#

class Invite < ApplicationRecord
  include Expireable

  belongs_to :user, inverse_of: :invites
  has_many :users, inverse_of: :invite

  scope :available, -> { where(expires_at: nil).or(where('expires_at >= ?', Time.now.utc)) }

  validates :comment, length: { maximum: 420 }
  # 招待リングが無制限に作成できないようにバリデーションチェックではじく
  validates :max_uses, presence: true
  validates :expires_at, presence: true

  before_validation :set_code

  def valid_for_use?
    (max_uses.nil? || uses < max_uses) && !expired? && user&.functional?
  end

  private

  def set_code
    loop do
      self.code = ([*('a'..'z'), *('A'..'Z'), *('0'..'9')] - %w(0 1 I l O)).sample(8).join
      break if Invite.find_by(code: code).nil?
    end
  end
end
