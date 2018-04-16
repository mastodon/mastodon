# encoding: utf-8
# frozen_string_literal: true
require 'mail/parsers/address_lists_parser'

module Mail
  class AddressList # :nodoc:
    attr_reader :addresses, :group_names

    # Mail::AddressList is the class that parses To, From and other address fields from
    # emails passed into Mail.
    #
    # AddressList provides a way to query the groups and mailbox lists of the passed in
    # string.
    #
    # It can supply all addresses in an array, or return each address as an address object.
    #
    # Mail::AddressList requires a correctly formatted group or mailbox list per RFC2822 or
    # RFC822.  It also handles all obsolete versions in those RFCs.
    #
    #  list = 'ada@test.lindsaar.net, My Group: mikel@test.lindsaar.net, Bob <bob@test.lindsaar.net>;'
    #  a = AddressList.new(list)
    #  a.addresses    #=> [#<Mail::Address:14943130 Address: |ada@test.lindsaar.net...
    #  a.group_names  #=> ["My Group"]
    def initialize(string)
      address_list = Parsers::AddressListsParser.parse(string)
      @addresses = address_list.addresses.map { |a| Address.new(a) }
      @group_names = address_list.group_names
    end

    def addresses_grouped_by_group
      addresses.select(&:group).group_by(&:group)
    end
  end
end
