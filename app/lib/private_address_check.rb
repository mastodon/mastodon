# frozen_string_literal: true

# Sources:
#  - RFC 1918 (private addressing)
#  - IANA IPv4 Special-Purpose Address Registry
#  - RFC 5735 / RFC 6890 / RFC 6598

module PrivateAddressCheck
  IP4_CIDR_LIST = [
    IPAddr.new('0.0.0.0/8'),            # Class A (reserved) — Current network (0.0.0.0 – 0.255.255.255)
    IPAddr.new('10.0.0.0/8'),           # Class A — RFC1918 private (10.0.0.0 – 10.255.255.255)
    IPAddr.new('11.0.0.0/8'),           # Class A — Former DoD (11.0.0.0 – 11.255.255.255)
    IPAddr.new('22.0.0.0/8'),           # Class A — Former DoD (22.0.0.0 – 22.255.255.255)
    IPAddr.new('30.0.0.0/8'),           # Class A — Former DoD (30.0.0.0 – 30.255.255.255)
    IPAddr.new('100.64.0.0/10'),        # Class A — CGNAT (100.64.0.0 – 100.127.255.255)
    IPAddr.new('127.0.0.0/8'),          # Class A (reserved) — Loopback (127.0.0.0 – 127.255.255.255)
    IPAddr.new('169.254.0.0/16'),       # Class B — Link-local (169.254.0.0 – 169.254.255.255)
    IPAddr.new('169.254.169.254/32'),   # Class B — Cloud metadata (169.254.169.254)
    IPAddr.new('172.16.0.0/12'),        # Class B — RFC1918 private (172.16.0.0 – 172.31.255.255)
    IPAddr.new('192.0.0.0/29'),         # Class C — Service Continuity (192.0.0.0 – 192.0.0.7)
    IPAddr.new('192.0.0.0/24'),         # Class C — IETF assignments (192.0.0.0 – 192.0.0.255)
    IPAddr.new('192.0.0.8/32'),         # Class C — Dummy address (192.0.0.8)
    IPAddr.new('192.0.0.170/32'),       # Class C — NAT64 part (192.0.0.170)
    IPAddr.new('192.0.0.171/32'),       # Class C — NAT64 part (192.0.0.171)
    IPAddr.new('192.0.2.0/24'),         # Class C — TEST-NET-1 (192.0.2.0 – 192.0.2.255)
    IPAddr.new('192.31.196.0/24'),      # Class C — AS112 sink (192.31.196.0 – 192.31.196.255)
    IPAddr.new('192.52.193.0/24'),      # Class C — AMT (192.52.193.0 – 192.52.193.255)
    IPAddr.new('192.88.99.0/24'),       # Class C — 6to4 relay (192.88.99.0 – 192.88.99.255)
    IPAddr.new('192.168.0.0/16'),       # Class C — RFC1918 private (192.168.0.0 – 192.168.255.255)
    IPAddr.new('192.175.48.0/24'),      # Class C — AS112 legacy (192.175.48.0 – 192.175.48.255)
    IPAddr.new('198.18.0.0/15'),        # Class C — Benchmark testing (198.18.0.0 – 198.19.255.255)
    IPAddr.new('198.32.0.0/16'),        # Class C — ORG-IANA multicast test (198.32.0.0 – 198.32.255.255)
    IPAddr.new('198.51.100.0/24'),      # Class C — TEST-NET-2 (198.51.100.0 – 198.51.100.255)
    IPAddr.new('203.0.113.0/24'),       # Class C — TEST-NET-3 (203.0.113.0 – 203.0.113.255)
    IPAddr.new('224.0.0.0/4'),          # Class D — Multicast (224.0.0.0 – 239.255.255.255)
    IPAddr.new('233.252.0.0/24'),       # Class D — MCAST-TEST-NET (233.252.0.0 – 233.252.0.255)
    IPAddr.new('240.0.0.0/4'),          # Class E — Reserved (240.0.0.0 – 255.255.255.255)
    IPAddr.new('255.255.255.255/32'),   # Class E — Limited broadcast (255.255.255.255)
  ].freeze

  # IPv6 special-purpose and non-globally-routable ranges
  IP6_CIDR_LIST = [
    IPAddr.new('::/128'),               # Unspecified (0000:0000:0000:0000:0000:0000:0000:0000)
    IPAddr.new('::1/128'),              # Loopback (0000:0000:0000:0000:0000:0000:0000:0001)
    IPAddr.new('::ffff:0:0/96'),        # IPv4-mapped IPv6 (0000:0000:0000:0000:0000:ffff:0000:0000 - 0000:0000:0000:0000:0000:ffff:ffff:ffff)
    IPAddr.new('64:ff9b::/96'),         # NAT64 WKP (0064:ff9b:0000:0000:0000:0000:0000:0000 - 0064:ff9b:0000:0000:0000:0000:ffff:ffff)
    IPAddr.new('64:ff9b:1::/48'),       # NAT64 locally assigned (0064:ff9b:0001:0000:0000:0000:0000:0000 - 0064:ff9b:0001:ffff:ffff:ffff:ffff:ffff)
    IPAddr.new('100::/64'),             # Discard prefix (0100:0000:0000:0000:0000:0000:0000:0000 - 0100:0000:0000:0000:ffff:ffff:ffff:ffff)
    IPAddr.new('2000::/3'),             # Global unicast (2000:0000:0000:0000:0000:0000:0000:0000 - 3fff:ffff:ffff:ffff:ffff:ffff:ffff:ffff)
    IPAddr.new('2001::/23'),            # IETF special (2001:0000:0000:0000:0000:0000:0000:0000 - 2001:01ff:ffff:ffff:ffff:ffff:ffff:ffff)
    IPAddr.new('2001::/32'),            # Teredo (2001:0000:0000:0000:0000:0000:0000:0000 - 2001:0000:ffff:ffff:ffff:ffff:ffff:ffff)
    IPAddr.new('2001:2::/48'),          # BMWG (2001:0002:0000:0000:0000:0000:0000:0000 - 2001:0002:0000:ffff:ffff:ffff:ffff:ffff)
    IPAddr.new('2001:3::/32'),          # AMT (2001:0003:0000:0000:0000:0000:0000:0000 - 2001:0003:ffff:ffff:ffff:ffff:ffff:ffff)
    IPAddr.new('2001:4:112::/48'),      # AS112 sink (2001:0004:0112:0000:0000:0000:0000:0000 - 2001:0004:0112:ffff:ffff:ffff:ffff:ffff)
    IPAddr.new('2001:10::/28'),         # ORCHID (2001:0010:0000:0000:0000:0000:0000:0000 - 2001:001f:ffff:ffff:ffff:ffff:ffff:ffff)
    IPAddr.new('2001:20::/28'),         # ORCHIDv2 (2001:0020:0000:0000:0000:0000:0000:0000 - 2001:002f:ffff:ffff:ffff:ffff:ffff:ffff)
    IPAddr.new('2001:db8::/32'),        # Documentation (2001:0db8:0000:0000:0000:0000:0000:0000 - 2001:0db8:ffff:ffff:ffff:ffff:ffff:ffff)
    IPAddr.new('2002::/16'),            # 6to4 (2002:0000:0000:0000:0000:0000:0000:0000 - 2002:ffff:ffff:ffff:ffff:ffff:ffff:ffff)
    IPAddr.new('3fff::/20'),            # 6bone legacy (3fff:0000:0000:0000:0000:0000:0000:0000 - 3fff:0fff:ffff:ffff:ffff:ffff:ffff:ffff)
    IPAddr.new('5f00::/8'),             # Former 6bone (5f00:0000:0000:0000:0000:0000:0000:0000 - 5fff:ffff:ffff:ffff:ffff:ffff:ffff:ffff)
    IPAddr.new('fc00::/7'),             # ULA (fc00:0000:0000:0000:0000:0000:0000:0000 - fdff:ffff:ffff:ffff:ffff:ffff:ffff:ffff)
    IPAddr.new('fd00::/8'),             # Locally assigned ULA (fd00:0000:0000:0000:0000:0000:0000:0000 - fdff:ffff:ffff:ffff:ffff:ffff:ffff:ffff)
    IPAddr.new('fe00::/9'),             # Reserved (fe00:0000:0000:0000:0000:0000:0000:0000 - fe7f:ffff:ffff:ffff:ffff:ffff:ffff:ffff)
    IPAddr.new('fec0::/10'),            # Site-local deprecated (fec0:0000:0000:0000:0000:0000:0000:0000 - feff:ffff:ffff:ffff:ffff:ffff:ffff:ffff)
    IPAddr.new('fe80::/10'),            # Link-local (fe80:0000:0000:0000:0000:0000:0000:0000 - febf:ffff:ffff:ffff:ffff:ffff:ffff:ffff)
    IPAddr.new('ff00::/8'),             # Multicast all (ff00:0000:0000:0000:0000:0000:0000:0000 - ffff:ffff:ffff:ffff:ffff:ffff:ffff:ffff)
    IPAddr.new('ff02::/16'),            # Multicast link-local (ff02:0000:0000:0000:0000:0000:0000:0000 - ff02:ffff:ffff:ffff:ffff:ffff:ffff:ffff)
    IPAddr.new('ff05::/16'),            # Multicast site-local (ff05:0000:0000:0000:0000:0000:0000:0000 - ff05:ffff:ffff:ffff:ffff:ffff:ffff:ffff)
    IPAddr.new('ff0e::/16'),            # Multicast global (ff0e:0000:0000:0000:0000:0000:0000:0000 - ff0e:ffff:ffff:ffff:ffff:ffff:ffff:ffff)
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
