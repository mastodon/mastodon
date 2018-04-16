# encoding: utf-8
# frozen_string_literal: true
require 'mail/parsers/address_lists_parser'

module Mail
  class Address
    include Mail::Utilities

    # Mail::Address handles all email addresses in Mail.  It takes an email address string
    # and parses it, breaking it down into its component parts and allowing you to get the
    # address, comments, display name, name, local part, domain part and fully formatted
    # address.
    #
    # Mail::Address requires a correctly formatted email address per RFC2822 or RFC822.  It
    # handles all obsolete versions including obsolete domain routing on the local part.
    #
    #  a = Address.new('Mikel Lindsaar (My email address) <mikel@test.lindsaar.net>')
    #  a.format       #=> 'Mikel Lindsaar <mikel@test.lindsaar.net> (My email address)'
    #  a.address      #=> 'mikel@test.lindsaar.net'
    #  a.display_name #=> 'Mikel Lindsaar'
    #  a.local        #=> 'mikel'
    #  a.domain       #=> 'test.lindsaar.net'
    #  a.comments     #=> ['My email address']
    #  a.to_s         #=> 'Mikel Lindsaar <mikel@test.lindsaar.net> (My email address)'
    def initialize(value = nil)
      if value.nil?
        @parsed = false
        @data = nil
      else
        parse(value)
      end
    end

    # Returns the raw input of the passed in string, this is before it is passed
    # by the parser.
    def raw
      @data.raw
    end

    # Returns a correctly formatted address for the email going out.  If given
    # an incorrectly formatted address as input, Mail::Address will do its best
    # to format it correctly.  This includes quoting display names as needed and
    # putting the address in angle brackets etc.
    #
    #  a = Address.new('Mikel Lindsaar (My email address) <mikel@test.lindsaar.net>')
    #  a.format #=> 'Mikel Lindsaar <mikel@test.lindsaar.net> (My email address)'
    def format(output_type = :decode)
      parse unless @parsed
      if @data.nil?
        EMPTY
      elsif name = display_name(output_type)
        [quote_phrase(name), "<#{address(output_type)}>", format_comments].compact.join(SPACE)
      elsif a = address(output_type)
        [a, format_comments].compact.join(SPACE)
      else
        raw
      end
    end

    # Returns the address that is in the address itself.  That is, the
    # local@domain string, without any angle brackets or the like.
    #
    #  a = Address.new('Mikel Lindsaar (My email address) <mikel@test.lindsaar.net>')
    #  a.address #=> 'mikel@test.lindsaar.net'
    def address(output_type = :decode)
      parse unless @parsed
      if d = domain(output_type)
        "#{local(output_type)}@#{d}"
      else
        local(output_type)
      end
    end

    # Provides a way to assign an address to an already made Mail::Address object.
    #
    #  a = Address.new
    #  a.address = 'Mikel Lindsaar (My email address) <mikel@test.lindsaar.net>'
    #  a.address #=> 'mikel@test.lindsaar.net'
    def address=(value)
      parse(value)
    end

    # Returns the display name of the email address passed in.
    #
    #  a = Address.new('Mikel Lindsaar (My email address) <mikel@test.lindsaar.net>')
    #  a.display_name #=> 'Mikel Lindsaar'
    def display_name(output_type = :decode)
      parse unless @parsed
      @display_name ||= get_display_name
      Encodings.decode_encode(@display_name.to_s, output_type) if @display_name
    end

    # Provides a way to assign a display name to an already made Mail::Address object.
    #
    #  a = Address.new
    #  a.address = 'mikel@test.lindsaar.net'
    #  a.display_name = 'Mikel Lindsaar'
    #  a.format #=> 'Mikel Lindsaar <mikel@test.lindsaar.net>'
    def display_name=( str )
      @display_name = str.nil? ? nil : str.dup # in case frozen
    end

    # Returns the local part (the left hand side of the @ sign in the email address) of
    # the address
    #
    #  a = Address.new('Mikel Lindsaar (My email address) <mikel@test.lindsaar.net>')
    #  a.local #=> 'mikel'
    def local(output_type = :decode)
      parse unless @parsed
      Encodings.decode_encode("#{@data.obs_domain_list}#{get_local.strip}", output_type) if get_local
    end

    # Returns the domain part (the right hand side of the @ sign in the email address) of
    # the address
    #
    #  a = Address.new('Mikel Lindsaar (My email address) <mikel@test.lindsaar.net>')
    #  a.domain #=> 'test.lindsaar.net'
    def domain(output_type = :decode)
      parse unless @parsed
      Encodings.decode_encode(strip_all_comments(get_domain), output_type) if get_domain
    end

    # Returns an array of comments that are in the email, or nil if there
    # are no comments
    #
    #  a = Address.new('Mikel Lindsaar (My email address) <mikel@test.lindsaar.net>')
    #  a.comments #=> ['My email address']
    #
    #  b = Address.new('Mikel Lindsaar <mikel@test.lindsaar.net>')
    #  b.comments #=> nil

    def comments
      parse unless @parsed
      comments = get_comments
      if comments.nil? || comments.none?
        nil
      else
        comments.map { |c| c.squeeze(SPACE) }
      end
    end

    # Sometimes an address will not have a display name, but might have the name
    # as a comment field after the address.  This returns that name if it exists.
    #
    #  a = Address.new('mikel@test.lindsaar.net (Mikel Lindsaar)')
    #  a.name #=> 'Mikel Lindsaar'
    def name
      parse unless @parsed
      get_name
    end

    # Returns the format of the address, or returns nothing
    #
    #  a = Address.new('Mikel Lindsaar (My email address) <mikel@test.lindsaar.net>')
    #  a.format #=> 'Mikel Lindsaar <mikel@test.lindsaar.net> (My email address)'
    def to_s
      parse unless @parsed
      format
    end

    # Shows the Address object basic details, including the Address
    #  a = Address.new('Mikel (My email) <mikel@test.lindsaar.net>')
    #  a.inspect #=> "#<Mail::Address:14184910 Address: |Mikel <mikel@test.lindsaar.net> (My email)| >"
    def inspect
      parse unless @parsed
      "#<#{self.class}:#{self.object_id} Address: |#{to_s}| >"
    end

    def encoded
      format :encode
    end

    def decoded
      format :decode
    end

    def group
      @data && @data.group
    end

    private

    def parse(value = nil)
      @parsed = true
      @data = nil

      case value
      when Mail::Parsers::AddressListsParser::AddressStruct
        @data = value
      when String
        unless Utilities.blank?(value)
          address_list = Mail::Parsers::AddressListsParser.parse(value)
          @data = address_list.addresses.first
        end
      end
    end

    def strip_all_comments(string)
      unless Utilities.blank?(comments)
        comments.each do |comment|
          string = string.gsub("(#{comment})", EMPTY)
        end
      end
      string.strip
    end

    def strip_domain_comments(value)
      unless Utilities.blank?(comments)
        comments.each do |comment|
          if @data.domain && @data.domain.include?("(#{comment})")
            value = value.gsub("(#{comment})", EMPTY)
          end
        end
      end
      value.to_s.strip
    end

    def get_display_name
      if @data && @data.display_name
        str = strip_all_comments(@data.display_name.to_s)
      elsif @data && @data.comments && @data.domain
        str = strip_domain_comments(format_comments)
      end
      str unless Utilities.blank?(str)
    end

    def get_name
      if display_name
        str = display_name
      elsif comments
        str = "(#{comments.join(SPACE).squeeze(SPACE)})"
      end

      unparen(str) unless Utilities.blank?(str)
    end

    def format_comments
      if comments
        comment_text = comments.map {|c| escape_paren(c) }.join(SPACE).squeeze(SPACE)
        @format_comments ||= "(#{comment_text})"
      else
        nil
      end
    end

    def get_local
      @data && @data.local
    end

    def get_domain
      @data && @data.domain
    end

    def get_comments
      @data && @data.comments
    end
  end
end
