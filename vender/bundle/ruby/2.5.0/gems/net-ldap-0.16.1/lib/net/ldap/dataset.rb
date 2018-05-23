# -*- ruby encoding: utf-8 -*-
##
# An LDAP Dataset. Used primarily as an intermediate format for converting
# to and from LDIF strings and Net::LDAP::Entry objects.
class Net::LDAP::Dataset < Hash
  ##
  # Dataset object version, comments.
  attr_accessor :version
  attr_reader   :comments

  def initialize(*args, &block) # :nodoc:
    super
    @version  = nil
    @comments = []
  end

  ##
  # Outputs an LDAP Dataset as an array of strings representing LDIF
  # entries.
  def to_ldif
    ary = []

    if version
      ary << "version: #{version}"
      ary << ""
    end

    ary += @comments unless @comments.empty?
    keys.sort.each do |dn|
      ary << "dn: #{dn}"

      attributes = self[dn].keys.map(&:to_s).sort
      attributes.each do |attr|
        self[dn][attr.to_sym].each do |value|
          if attr == "userpassword" or value_is_binary?(value)
            value = [value].pack("m").chomp.gsub(/\n/m, "\n ")
            ary << "#{attr}:: #{value}"
          else
            ary << "#{attr}: #{value}"
          end
        end
      end

      ary << ""
    end
    block_given? and ary.each { |line| yield line}

    ary
  end

  ##
  # Outputs an LDAP Dataset as an LDIF string.
  def to_ldif_string
    to_ldif.join("\n")
  end

  ##
  # Convert the parsed LDIF objects to Net::LDAP::Entry objects.
  def to_entries
    ary = []
    keys.each do |dn|
      entry = Net::LDAP::Entry.new(dn)
      self[dn].each do |attr, value|
        entry[attr] = value
      end
      ary << entry
    end
    ary
  end

  ##
  # This is an internal convenience method to determine if a value requires
  # base64-encoding before conversion to LDIF output. The standard approach
  # in most LDAP tools is to check whether the value is a password, or if
  # the first or last bytes are non-printable. Microsoft Active Directory,
  # on the other hand, sometimes sends values that are binary in the middle.
  #
  # In the worst cases, this could be a nasty performance killer, which is
  # why we handle the simplest cases first. Ideally, we would also test the
  # first/last byte, but it's a bit harder to do this in a way that's
  # compatible with both 1.8.6 and 1.8.7.
  def value_is_binary?(value) # :nodoc:
    value = value.to_s
    return true if value[0] == ?: or value[0] == ?<
    value.each_byte { |byte| return true if (byte < 32) || (byte > 126) }
    false
  end
  private :value_is_binary?

  class << self
    class ChompedIO # :nodoc:
      def initialize(io)
        @io = io
      end
      def gets
        s = @io.gets
        s.chomp if s
      end
    end

    ##
    # Creates a Dataset object from an Entry object. Used mostly to assist
    # with the conversion of
    def from_entry(entry)
      dataset = Net::LDAP::Dataset.new
      hash = { }
      entry.each_attribute do |attribute, value|
        next if attribute == :dn
        hash[attribute] = value
      end
      dataset[entry.dn] = hash
      dataset
    end

    ##
    # Reads an object that returns data line-wise (using #gets) and parses
    # LDIF data into a Dataset object.
    def read_ldif(io)
      ds = Net::LDAP::Dataset.new
      io = ChompedIO.new(io)

      line = io.gets
      dn = nil

      while line
        new_line = io.gets

        if new_line =~ /^ /
          line << $'
        else
          nextline = new_line

          if line =~ /^#/
            ds.comments << line
            yield :comment, line if block_given?
          elsif line =~ /^version:[\s]*([0-9]+)$/i
            ds.version = $1
            yield :version, line if block_given?
          elsif line =~ /^dn:([\:]?)[\s]*/i
            # $1 is a colon if the dn-value is base-64 encoded
            # $' is the dn-value
            # Avoid the Base64 class because not all Ruby versions have it.
            dn = ($1 == ":") ? $'.unpack('m').shift : $'
            ds[dn] = Hash.new { |k, v| k[v] = [] }
            yield :dn, dn if block_given?
          elsif line.empty?
            dn = nil
            yield :end, nil if block_given?
          elsif line =~ /^([^:]+):([\:]?)[\s]*/
            # $1 is the attribute name
            # $2 is a colon iff the attr-value is base-64 encoded
            # $' is the attr-value
            # Avoid the Base64 class because not all Ruby versions have it.
            attrvalue = ($2 == ":") ? $'.unpack('m').shift : $'
            ds[dn][$1.downcase.to_sym] << attrvalue
            yield :attr, [$1.downcase.to_sym, attrvalue] if block_given?
          end

          line = nextline
        end
      end

      ds
    end
  end
end

require 'net/ldap/entry' unless defined? Net::LDAP::Entry
