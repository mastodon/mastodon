# frozen_string_literal: true

# == Schema Information
#
# Table name: invites
#
#  id         :bigint(8)        not null, primary key
#  autofollow :boolean          default(FALSE), not null
#  code       :string           default(""), not null
#  comment    :text
#  expires_at :datetime
#  max_uses   :integer
#  uses       :integer          default(0), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :bigint(8)        not null
#

class Invite < ApplicationRecord
  include Expireable

  COMMENT_SIZE_LIMIT = 420
  ELIGIBLE_CODE_CHARACTERS = [*('a'..'z'), *('A'..'Z'), *('0'..'9')].freeze
  EXPIRATION_DURATIONS = [30.minutes, 1.hour, 6.hours, 12.hours, 1.day, 1.week].freeze
  HOMOGLYPHS = %w(0 1 I l O).freeze
  MAX_USES_COUNTS = [1, 5, 10, 25, 50, 100].freeze
  VALID_CODE_CHARACTERS = (ELIGIBLE_CODE_CHARACTERS - HOMOGLYPHS).freeze

  belongs_to :user, inverse_of: :invites
  has_many :users, inverse_of: :invite, dependent: nil

  scope :available, -> { where(expires_at: nil).or(where(expires_at: Time.now.utc..)) }

  validates :comment, length: { maximum: COMMENT_SIZE_LIMIT }

  before_validation :set_code, on: :create

  def valid_for_use?
    (max_uses.nil? || uses < max_uses) && !expired? && user&.functional?
  end

  def bypass_approval?
    user&.role&.can?(:invite_bypass_approval)
  end

  private

  def set_code
    loop do
      self.code = VALID_CODE_CHARACTERS.sample(8).join
      break if Invite.find_by(code: code).nil?
    end
  end
end
