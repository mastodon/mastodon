# frozen_string_literal: true

class FastIpMap
  MAX_IPV4_PREFIX = 32
  MAX_IPV6_PREFIX = 128

  # @param [Enumerable<IPAddr>] addresses
  def initialize(addresses)
    @fast_lookup = {}
    @ranges      = []

    # Hash look-up is faster but only works for exact matches, so we split
    # exact addresses from non-exact ones
    addresses.each do |address|
      if (address.ipv4? && address.prefix == MAX_IPV4_PREFIX) || (address.ipv6? && address.prefix == MAX_IPV6_PREFIX)
        @fast_lookup[address.to_s] = true
      else
        @ranges << address
      end
    end

    # We're more likely to hit wider-reaching ranges when checking for
    # inclusion, so make sure they're sorted first
    @ranges.sort_by!(&:prefix)
  end

  # @param [IPAddr] address
  # @return [Boolean]
  def include?(address)
    @fast_lookup[address.to_s] || @ranges.any? { |cidr| cidr.include?(address) }
  end
end
