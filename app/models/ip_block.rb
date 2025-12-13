# frozen_string_literal: true

# == Schema Information
#
# Table name: ip_blocks
#
#  id         :bigint(8)        not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  expires_at :datetime
#  ip         :inet             default(#<IPAddr: IPv4:0.0.0.0/255.255.255.255>), not null
#  severity   :integer          default(NULL), not null
#  comment    :text             default(""), not null
#

class IpBlock < ApplicationRecord
  CACHE_KEY = 'blocked_ips'

  include Expireable
  include InetContainer
  include Paginable

  enum :severity, {
    sign_up_requires_approval: 5000,
    sign_up_block: 5500,
    no_access: 9999,
  }, prefix: true, validate: true

  validates :ip, :severity, presence: true
  validates :ip, uniqueness: true

  after_commit :reset_cache

  def to_cidr
    "#{ip}/#{ip.prefix}"
  end
  alias to_log_human_identifier to_cidr

  class << self
    def blocked?(remote_ip)
      blocked_ips_map.include?(remote_ip)
    end

    private

    def blocked_ips_map
      Rails.cache.fetch(CACHE_KEY) { FastIpMap.new(severity_no_access.pluck(:ip)) }
    end
  end

  private

  def reset_cache
    Rails.cache.delete(CACHE_KEY)
  end
end
