# frozen_string_literal: true
# == Schema Information
#
# Table name: unavailable_domains
#
#  id         :bigint(8)        not null, primary key
#  domain     :string           default(""), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class UnavailableDomain < ApplicationRecord
  include DomainNormalizable

  validates :domain, presence: true, uniqueness: true

  after_commit :reset_cache!

  private

  def reset_cache!
    Rails.cache.delete('unavailable_domains')
  end
end
