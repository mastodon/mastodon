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
#

class Invite < ApplicationRecord
  belongs_to :user
  has_many :users, inverse_of: :invite

  scope :available, -> { where(expires_at: nil).or(where('expires_at >= ?', Time.now.utc)) }
  scope :expired, -> { where.not(expires_at: nil).where('expires_at < ?', Time.now.utc) }

  before_validation :set_code

  attr_reader :expires_in

  def expires_in=(interval)
    self.expires_at = interval.to_i.seconds.from_now unless interval.blank?
    @expires_in     = interval
  end

  def valid_for_use?
    (max_uses.nil? || uses < max_uses) && !expired?
  end

  def expire!
    touch(:expires_at)
  end

  def expired?
    !expires_at.nil? && expires_at < Time.now.utc
  end

  private

  def set_code
    loop do
      self.code = ([*('a'..'z'), *('A'..'Z'), *('0'..'9')] - %w(0 1 I l O)).sample(8).join
      break if Invite.find_by(code: code).nil?
    end
  end
end
