# frozen_string_literal: true
# == Schema Information
#
# Table name: canonical_email_blocks
#
#  id                   :bigint(8)        not null, primary key
#  canonical_email_hash :string           default(""), not null
#  reference_account_id :bigint(8)
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#

class CanonicalEmailBlock < ApplicationRecord
  include EmailHelper
  include Paginable

  belongs_to :reference_account, class_name: 'Account', optional: true

  validates :canonical_email_hash, presence: true, uniqueness: true

  scope :matching_email, ->(email) { where(canonical_email_hash: email_to_canonical_email_hash(email)) }

  def to_log_human_identifier
    canonical_email_hash
  end

  def email=(email)
    self.canonical_email_hash = email_to_canonical_email_hash(email)
  end

  def self.block?(email)
    matching_email(email).exists?
  end
end
