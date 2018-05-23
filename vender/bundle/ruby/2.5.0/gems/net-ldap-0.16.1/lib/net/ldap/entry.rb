# -*- ruby encoding: utf-8 -*-
##
# Objects of this class represent individual entries in an LDAP directory.
# User code generally does not instantiate this class. Net::LDAP#search
# provides objects of this class to user code, either as block parameters or
# as return values.
#
# In LDAP-land, an "entry" is a collection of attributes that are uniquely
# and globally identified by a DN ("Distinguished Name"). Attributes are
# identified by short, descriptive words or phrases. Although a directory is
# free to implement any attribute name, most of them follow rigorous
# standards so that the range of commonly-encountered attribute names is not
# large.
#
# An attribute name is case-insensitive. Most directories also restrict the
# range of characters allowed in attribute names. To simplify handling
# attribute names, Net::LDAP::Entry internally converts them to a standard
# format. Therefore, the methods which take attribute names can take Strings
# or Symbols, and work correctly regardless of case or capitalization.
#
# An attribute consists of zero or more data items called <i>values.</i> An
# entry is the combination of a unique DN, a set of attribute names, and a
# (possibly-empty) array of values for each attribute.
#
# Class Net::LDAP::Entry provides convenience methods for dealing with LDAP
# entries. In addition to the methods documented below, you may access
# individual attributes of an entry simply by giving the attribute name as
# the name of a method call. For example:
#
#   ldap.search( ... ) do |entry|
#     puts "Common name: #{entry.cn}"
#     puts "Email addresses:"
#     entry.mail.each {|ma| puts ma}
#   end
#
# If you use this technique to access an attribute that is not present in a
# particular Entry object, a NoMethodError exception will be raised.
#
#--
# Ugly problem to fix someday: We key off the internal hash with a canonical
# form of the attribute name: convert to a string, downcase, then take the
# symbol. Unfortunately we do this in at least three places. Should do it in
# ONE place.
class Net::LDAP::Entry
  ##
  # This constructor is not generally called by user code.
  def initialize(dn = nil) #:nodoc:
    @myhash = {}
    @myhash[:dn] = [dn]
  end

  ##
  # Use the LDIF format for Marshal serialization.
  def _dump(depth) #:nodoc:
    to_ldif
  end

  ##
  # Use the LDIF format for Marshal serialization.
  def self._load(entry) #:nodoc:
    from_single_ldif_string(entry)
  end

  class << self
    ##
    # Converts a single LDIF entry string into an Entry object. Useful for
    # Marshal serialization. If a string with multiple LDIF entries is
    # provided, an exception will be raised.
    def from_single_ldif_string(ldif)
      ds = Net::LDAP::Dataset.read_ldif(::StringIO.new(ldif))

      return nil if ds.empty?

      raise Net::LDAP::EntryOverflowError, "Too many LDIF entries" unless ds.size == 1

      entry = ds.to_entries.first

      return nil if entry.dn.nil?
      entry
    end

    ##
    # Canonicalizes an LDAP attribute name as a \Symbol. The name is
    # lowercased and, if present, a trailing equals sign is removed.
    def attribute_name(name)
      name = name.to_s.downcase
      name = name[0..-2] if name[-1] == ?=
      name.to_sym
    end
  end

  ##
  # Sets or replaces the array of values for the provided attribute. The
  # attribute name is canonicalized prior to assignment.
  #
  # When an attribute is set using this, that attribute is now made
  # accessible through methods as well.
  #
  #   entry = Net::LDAP::Entry.new("dc=com")
  #   entry.foo             # => NoMethodError
  #   entry["foo"] = 12345  # => [12345]
  #   entry.foo             # => [12345]
  def []=(name, value)
    @myhash[self.class.attribute_name(name)] = Kernel::Array(value)
  end

  ##
  # Reads the array of values for the provided attribute. The attribute name
  # is canonicalized prior to reading. Returns an empty array if the
  # attribute does not exist.
  def [](name)
    name = self.class.attribute_name(name)
    @myhash[name] || []
  end

  ##
  # Read the first value for the provided attribute. The attribute name
  # is canonicalized prior to reading. Returns nil if the attribute does
  # not exist.
  def first(name)
    self[name].first
  end

  ##
  # Returns the first distinguished name (dn) of the Entry as a \String.
  def dn
    self[:dn].first.to_s
  end

  ##
  # Returns an array of the attribute names present in the Entry.
  def attribute_names
    @myhash.keys
  end

  ##
  # Accesses each of the attributes present in the Entry.
  #
  # Calls a user-supplied block with each attribute in turn, passing two
  # arguments to the block: a Symbol giving the name of the attribute, and a
  # (possibly empty) \Array of data values.
  def each # :yields: attribute-name, data-values-array
    return unless block_given?
    attribute_names.each do|a|
      attr_name, values = a, self[a]
      yield attr_name, values
    end
  end
  alias_method :each_attribute, :each

  ##
  # Converts the Entry to an LDIF-formatted String
  def to_ldif
    Net::LDAP::Dataset.from_entry(self).to_ldif_string
  end

  def respond_to?(sym, include_all = false) #:nodoc:
    return true if valid_attribute?(self.class.attribute_name(sym))
    return super
  end

  def method_missing(sym, *args, &block) #:nodoc:
    name = self.class.attribute_name(sym)

    if valid_attribute?(name )
      if setter?(sym) && args.size == 1
        value = args.first
        value = Array(value)
        self[name]= value
        return value
      elsif args.empty?
        return self[name]
      end
    end

    super
  end

  # Given a valid attribute symbol, returns true.
  def valid_attribute?(attr_name)
    attribute_names.include?(attr_name)
  end
  private :valid_attribute?

  # Returns true if the symbol ends with an equal sign.
  def setter?(sym)
    sym.to_s[-1] == ?=
  end
  private :setter?
end # class Entry

require 'net/ldap/dataset' unless defined? Net::LDAP::Dataset
