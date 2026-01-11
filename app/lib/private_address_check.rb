# frozen_string_literal: true

# Sources:
#   - RFC 1918 (private addressing)
#   - IANA IPv4 Special-Purpose Address Registry
#   - RFC 5735 / RFC 6890 / RFC 6598

module PrivateAddressCheck
  IP4_CIDR_LIST = [
    IPAddr.new('0.0.0.0/8'),          # Class A (reserved) — Current network (only valid as source address)
    IPAddr.new('10.0.0.0/8'),         # Class A — RFC1918 private
    IPAddr.new('100.64.0.0/10'),      # Class A — Carrier-grade NAT (CGNAT)
    IPAddr.new('127.0.0.0/8'),        # Class A (reserved) — Loopback
    IPAddr.new('169.254.0.0/16'),     # Class B — Link-local
    IPAddr.new('172.16.0.0/12'),      # Class B — RFC1918 private
    IPAddr.new('192.0.0.0/29'),       # Class C — IPv4 Service Continuity Prefix
    IPAddr.new('192.0.0.0/24'),       # Class C — IETF protocol assignments
    IPAddr.new('192.0.0.8/32'),       # Class C — IPv4 dummy address
    IPAddr.new('192.0.0.170/32'),     # Class C — NAT64 well-known prefix (part)
    IPAddr.new('192.0.0.171/32'),     # Class C — NAT64 well-known prefix (part)
    IPAddr.new('192.0.2.0/24'),       # Class C — TEST-NET-1 (documentation)
    IPAddr.new('192.88.99.0/24'),     # Class C — 6to4 relay anycast (deprecated)
    IPAddr.new('192.168.0.0/16'),     # Class C — RFC1918 private
    IPAddr.new('192.175.48.0/24'),    # Class C — AS112 sink
    IPAddr.new('198.18.0.0/15'),      # Class C — Network benchmark testing
    IPAddr.new('198.51.100.0/24'),    # Class C — TEST-NET-2 (documentation)
    IPAddr.new('203.0.113.0/24'),     # Class C — TEST-NET-3 (documentation)
    IPAddr.new('224.0.0.0/4'),        # Class D — Multicast
    IPAddr.new('240.0.0.0/4'),        # Class E — Reserved (future use)
    IPAddr.new('255.255.255.255/32'), # Class E — Limited broadcast
  ].freeze

  # IPv6 special-purpose and non-globally-routable ranges
  IP6_CIDR_LIST = [
    IPAddr.new('::/128'),             # Unspecified
    IPAddr.new('::1/128'),            # Loopback
    IPAddr.new('::ffff:0:0/96'),      # IPv4-mapped IPv6 addresses
    IPAddr.new('64:ff9b::/96'),       # NAT64 WKP
    IPAddr.new('64:ff9b:1::/48'),     # NAT64 locally assigned
    IPAddr.new('100::/64'),           # Discard prefix
    IPAddr.new('2001::/32'),          # Teredo
    IPAddr.new('2001:10::/28'),       # ORCHID (deprecated)
    IPAddr.new('2001:20::/28'),       # ORCHIDv2
    IPAddr.new('2001:db8::/32'),      # Documentation
    IPAddr.new('2002::/16'),          # 6to4
    IPAddr.new('fc00::/7'),           # Unique local address (ULA)
    IPAddr.new('fe80::/10'),          # Link-local unicast
    IPAddr.new('ff00::/8'),           # Multicast
  ].freeze

  CIDR_LIST = (
    IP4_CIDR_LIST +
    IP4_CIDR_LIST.map(&:ipv4_mapped) +
    IP6_CIDR_LIST
  ).freeze

  module_function

  def private_address?(address)
    address = address.native
    raise ArgumentError, "IPAddr mismatch, #{address.class}" unless address.is_a?(IPAddr)

    address.private? || address.loopback? || address.link_local? || CIDR_LIST.any? { |cidr| cidr.include?(address) }
  end
end
