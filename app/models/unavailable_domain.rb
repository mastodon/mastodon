# frozen_string_literal: true

class UnavailableDomain < ApplicationRecord
  include DomainNormalizable

  validates :domain, presence: true, uniqueness: true

  after_commit :reset_cache!

  def to_log_human_identifier
    domain
  end

  private

  def reset_cache!
    Rails.cache.delete('unavailable_domains')
  end
end
