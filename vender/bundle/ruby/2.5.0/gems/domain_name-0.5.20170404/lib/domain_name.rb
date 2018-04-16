# -*- coding: utf-8 -*-
#
# domain_name.rb - Domain Name manipulation library for Ruby
#
# Copyright (C) 2011-2017 Akinori MUSHA, All rights reserved.
#

require 'domain_name/version'
require 'domain_name/punycode'
require 'domain_name/etld_data'
require 'unf'
require 'ipaddr'

# Represents a domain name ready for extracting its registered domain
# and TLD.
class DomainName
  # The full host name normalized, ASCII-ized and downcased using the
  # Unicode NFC rules and the Punycode algorithm.  If initialized with
  # an IP address, the string representation of the IP address
  # suitable for opening a connection to.
  attr_reader :hostname

  # The Unicode representation of the #hostname property.
  #
  # :attr_reader: hostname_idn

  # The least "universally original" domain part of this domain name.
  # For example, "example.co.uk" for "www.sub.example.co.uk".  This
  # may be nil if the hostname does not have one, like when it is an
  # IP address, an effective TLD or higher itself, or of a
  # non-canonical domain.
  attr_reader :domain

  # The Unicode representation of the #domain property.
  #
  # :attr_reader: domain_idn

  # The TLD part of this domain name.  For example, if the hostname is
  # "www.sub.example.co.uk", the TLD part is "uk".  This property is
  # nil only if +ipaddr?+ is true.  This may be nil if the hostname
  # does not have one, like when it is an IP address or of a
  # non-canonical domain.
  attr_reader :tld

  # The Unicode representation of the #tld property.
  #
  # :attr_reader: tld_idn

  # Returns an IPAddr object if this is an IP address.
  attr_reader :ipaddr

  # Returns true if this is an IP address, such as "192.168.0.1" and
  # "[::1]".
  def ipaddr?
    @ipaddr ? true : false
  end

  # Returns a host name representation suitable for use in the host
  # name part of a URI.  A host name, an IPv4 address, or a IPv6
  # address enclosed in square brackets.
  attr_reader :uri_host

  # Returns true if this domain name has a canonical TLD.
  def canonical_tld?
    @canonical_tld_p
  end

  # Returns true if this domain name has a canonical registered
  # domain.
  def canonical?
    @canonical_tld_p && (@domain ? true : false)
  end

  DOT = '.'.freeze	# :nodoc:

  # Parses _hostname_ into a DomainName object.  An IP address is also
  # accepted.  An IPv6 address may be enclosed in square brackets.
  def initialize(hostname)
    hostname.is_a?(String) or
      (hostname.respond_to?(:to_str) && (hostname = hostname.to_str).is_a?(String)) or
      raise TypeError, "#{hostname.class} is not a String"
    if hostname.start_with?(DOT)
      raise ArgumentError, "domain name must not start with a dot: #{hostname}"
    end
    case hostname
    when /\A([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+)\z/
      @ipaddr = IPAddr.new($1)
      @uri_host = @hostname = @ipaddr.to_s
      @domain = @tld = nil
      return
    when /\A([0-9A-Fa-f:]*:[0-9A-Fa-f:]*:[0-9A-Fa-f:]*)\z/,
      /\A\[([0-9A-Fa-f:]*:[0-9A-Fa-f:]*:[0-9A-Fa-f:]*)\]\z/
      @ipaddr = IPAddr.new($1)
      @hostname = @ipaddr.to_s
      @uri_host = "[#{@hostname}]"
      @domain = @tld = nil
      return
    end
    @ipaddr = nil
    @hostname = DomainName.normalize(hostname)
    @uri_host = @hostname
    if last_dot = @hostname.rindex(DOT)
      @tld = @hostname[(last_dot + 1)..-1]
    else
      @tld = @hostname
    end
    etld_data = DomainName.etld_data
    if @canonical_tld_p = etld_data.key?(@tld)
      subdomain = domain = nil
      parent = @hostname
      loop {
        case etld_data[parent]
        when 0
          @domain = domain
          return
        when -1
          @domain = subdomain
          return
        when 1
          @domain = parent
          return
        end
        subdomain = domain
        domain = parent
        pos = @hostname.index(DOT, -domain.length) or break
        parent = @hostname[(pos + 1)..-1]
      }
    else
      # unknown/local TLD
      if last_dot
        # fallback - accept cookies down to second level
        # cf. http://www.dkim-reputation.org/regdom-libs/
        if penultimate_dot = @hostname.rindex(DOT, last_dot - 1)
          @domain = @hostname[(penultimate_dot + 1)..-1]
        else
          @domain = @hostname
        end
      else
        # no domain part - must be a local hostname
        @domain = @tld
      end
    end
  end

  # Checks if the server represented by this domain is qualified to
  # send and receive cookies with a domain attribute value of
  # _domain_.  A true value given as the second argument represents
  # cookies without a domain attribute value, in which case only
  # hostname equality is checked.
  def cookie_domain?(domain, host_only = false)
    # RFC 6265 #5.3
    # When the user agent "receives a cookie":
    return self == domain if host_only

    domain = DomainName.new(domain) unless DomainName === domain
    if ipaddr?
      # RFC 6265 #5.1.3
      # Do not perform subdomain matching against IP addresses.
      @hostname == domain.hostname
    else
      # RFC 6265 #4.1.1
      # Domain-value must be a subdomain.
      @domain && self <= domain && domain <= @domain ? true : false
    end
  end

  # Returns the superdomain of this domain name.
  def superdomain
    return nil if ipaddr?
    pos = @hostname.index(DOT) or return nil
    self.class.new(@hostname[(pos + 1)..-1])
  end

  def ==(other)
    other = DomainName.new(other) unless DomainName === other
    other.hostname == @hostname
  end

  def <=>(other)
    other = DomainName.new(other) unless DomainName === other
    othername = other.hostname
    if othername == @hostname
      0
    elsif @hostname.end_with?(othername) && @hostname[-othername.size - 1, 1] == DOT
      # The other is higher
      -1
    elsif othername.end_with?(@hostname) && othername[-@hostname.size - 1, 1] == DOT
      # The other is lower
      1
    else
      nil
    end
  end

  def <(other)
    case self <=> other
    when -1
      true
    when nil
      nil
    else
      false
    end
  end

  def >(other)
    case self <=> other
    when 1
      true
    when nil
      nil
    else
      false
    end
  end

  def <=(other)
    case self <=> other
    when -1, 0
      true
    when nil
      nil
    else
      false
    end
  end

  def >=(other)
    case self <=> other
    when 1, 0
      true
    when nil
      nil
    else
      false
    end
  end

  def to_s
    @hostname
  end

  alias to_str to_s

  def hostname_idn
    @hostname_idn ||=
      if @ipaddr
        @hostname
      else
        DomainName::Punycode.decode_hostname(@hostname)
      end
  end

  alias idn hostname_idn

  def domain_idn
    @domain_idn ||=
      if @ipaddr
        @domain
      else
        DomainName::Punycode.decode_hostname(@domain)
      end
  end

  def tld_idn
    @tld_idn ||=
      if @ipaddr
        @tld
      else
        DomainName::Punycode.decode_hostname(@tld)
      end
  end

  def inspect
    str = '#<%s:%s' % [self.class.name, @hostname]
    if @ipaddr
      str << ' (ipaddr)'
    else
      str << ' domain=' << @domain if @domain
      str << ' tld=' << @tld if @tld
    end
    str << '>'
  end

  class << self
    # Normalizes a _domain_ using the Punycode algorithm as necessary.
    # The result will be a downcased, ASCII-only string.
    def normalize(domain)
      DomainName::Punycode.encode_hostname(domain.chomp(DOT).to_nfc).downcase
    end
  end
end

# Short hand for DomainName.new().
def DomainName(hostname)
  DomainName.new(hostname)
end
