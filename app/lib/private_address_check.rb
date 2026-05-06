# frozen_string_literal: true

module PrivateAddressCheck
  IP4_CIDR_LIST = [
    IPAddr.new('0.0.0.0/8'),       # Current network (only valid as source address)
    IPAddr.new('100.64.0.0/10'),   # Shared Address Space
    IPAddr.new('172.16.0.0/12'),   # Private network
    IPAddr.new('192.0.0.0/24'),    # IETF Protocol Assignments
    IPAddr.new('192.0.2.0/24'),    # TEST-NET-1, documentation and examples
    IPAddr.new('192.88.99.0/24'),  # IPv6 to IPv4 relay (includes 2002::/16)
    IPAddr.new('198.18.0.0/15'),   # Network benchmark tests
    IPAddr.new('198.51.100.0/24'), # TEST-NET-2, documentation and examples
    IPAddr.new('203.0.113.0/24'),  # TEST-NET-3, documentation and examples
    IPAddr.new('224.0.0.0/4'),     # IP multicast (former Class D network)
    IPAddr.new('240.0.0.0/4'),     # Reserved (former Class E network)
    IPAddr.new('255.255.255.255'), # Broadcast
  ].freeze

  CIDR_LIST = (IP4_CIDR_LIST + IP4_CIDR_LIST.map(&:ipv4_mapped) + [
    IPAddr.new('64:ff9b::/96'),    # IPv4/IPv6 translation (RFC 6052)
    IPAddr.new('100::/64'),        # Discard prefix (RFC 6666)
    IPAddr.new('2001::/32'),       # Teredo tunneling
    IPAddr.new('2001:10::/28'),    # Deprecated (previously ORCHID)
    IPAddr.new('2001:20::/28'),    # ORCHIDv2
    IPAddr.new('2001:db8::/32'),   # Addresses used in documentation and example source code
    IPAddr.new('2002::/16'),       # 6to4
    IPAddr.new('fc00::/7'),        # Unique local address
    IPAddr.new('ff00::/8'),        # Multicast
  ]).freeze

  module_function

  def private_address?(address)
    address.private? || address.loopback? || address.link_local? || CIDR_LIST.any? { |cidr| cidr.include?(address) }
  end
end
