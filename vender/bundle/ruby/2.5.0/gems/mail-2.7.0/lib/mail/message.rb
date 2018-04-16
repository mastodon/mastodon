# encoding: utf-8
# frozen_string_literal: true
require "yaml"

module Mail
  # The Message class provides a single point of access to all things to do with an
  # email message.
  #
  # You create a new email message by calling the Mail::Message.new method, or just
  # Mail.new
  #
  # A Message object by default has the following objects inside it:
  #
  # * A Header object which contains all information and settings of the header of the email
  # * Body object which contains all parts of the email that are not part of the header, this
  #   includes any attachments, body text, MIME parts etc.
  #
  # ==Per RFC2822
  #
  #  2.1. General Description
  #
  #   At the most basic level, a message is a series of characters.  A
  #   message that is conformant with this standard is comprised of
  #   characters with values in the range 1 through 127 and interpreted as
  #   US-ASCII characters [ASCII].  For brevity, this document sometimes
  #   refers to this range of characters as simply "US-ASCII characters".
  #
  #   Note: This standard specifies that messages are made up of characters
  #   in the US-ASCII range of 1 through 127.  There are other documents,
  #   specifically the MIME document series [RFC2045, RFC2046, RFC2047,
  #   RFC2048, RFC2049], that extend this standard to allow for values
  #   outside of that range.  Discussion of those mechanisms is not within
  #   the scope of this standard.
  #
  #   Messages are divided into lines of characters.  A line is a series of
  #   characters that is delimited with the two characters carriage-return
  #   and line-feed; that is, the carriage return (CR) character (ASCII
  #   value 13) followed immediately by the line feed (LF) character (ASCII
  #   value 10).  (The carriage-return/line-feed pair is usually written in
  #   this document as "CRLF".)
  #
  #   A message consists of header fields (collectively called "the header
  #   of the message") followed, optionally, by a body.  The header is a
  #   sequence of lines of characters with special syntax as defined in
  #   this standard. The body is simply a sequence of characters that
  #   follows the header and is separated from the header by an empty line
  #   (i.e., a line with nothing preceding the CRLF).
  class Message

    include Constants
    include Utilities

    # ==Making an email
    #
    # You can make an new mail object via a block, passing a string, file or direct assignment.
    #
    # ===Making an email via a block
    #
    #  mail = Mail.new do |m|
    #    m.from 'mikel@test.lindsaar.net'
    #    m.to 'you@test.lindsaar.net'
    #    m.subject 'This is a test email'
    #    m.body File.read('body.txt')
    #  end
    #
    #  mail.to_s #=> "From: mikel@test.lindsaar.net\r\nTo: you@...
    #
    # If may also pass a block with no arguments, in which case it will
    # be evaluated in the scope of the new message instance:
    #
    #  mail = Mail.new do
    #    from 'mikel@test.lindsaar.net'
    #    # …
    #  end
    #
    # ===Making an email via passing a string
    #
    #  mail = Mail.new("To: mikel@test.lindsaar.net\r\nSubject: Hello\r\n\r\nHi there!")
    #  mail.body.to_s #=> 'Hi there!'
    #  mail.subject   #=> 'Hello'
    #  mail.to        #=> 'mikel@test.lindsaar.net'
    #
    # ===Making an email from a file
    #
    #  mail = Mail.read('path/to/file.eml')
    #  mail.body.to_s #=> 'Hi there!'
    #  mail.subject   #=> 'Hello'
    #  mail.to        #=> 'mikel@test.lindsaar.net'
    #
    # ===Making an email via assignment
    #
    # You can assign values to a mail object via four approaches:
    #
    # * Message#field_name=(value)
    # * Message#field_name(value)
    # * Message#['field_name']=(value)
    # * Message#[:field_name]=(value)
    #
    # Examples:
    #
    #  mail = Mail.new
    #  mail['from'] = 'mikel@test.lindsaar.net'
    #  mail[:to]    = 'you@test.lindsaar.net'
    #  mail.subject 'This is a test email'
    #  mail.body    = 'This is a body'
    #
    #  mail.to_s #=> "From: mikel@test.lindsaar.net\r\nTo: you@...
    #
    def initialize(*args, &block)
      @body = nil
      @body_raw = nil
      @separate_parts = false
      @text_part = nil
      @html_part = nil
      @errors = nil
      @header = nil
      @charset = self.class.default_charset
      @defaulted_charset = true

      @smtp_envelope_from = nil
      @smtp_envelope_to = nil

      @perform_deliveries = true
      @raise_delivery_errors = true

      @delivery_handler = nil

      @delivery_method = Mail.delivery_method.dup

      @transport_encoding = Mail::Encodings.get_encoding('7bit')

      @mark_for_delete = false

      if args.flatten.first.respond_to?(:each_pair)
        init_with_hash(args.flatten.first)
      else
        init_with_string(args.flatten[0].to_s)
      end

      # Support both builder styles:
      #
      #   Mail.new do
      #     to 'recipient@example.com'
      #   end
      #
      # and
      #
      #   Mail.new do |m|
      #     m.to 'recipient@example.com'
      #   end
      if block_given?
        if block.arity.zero? || (RUBY_VERSION < '1.9' && block.arity < 1)
          instance_eval(&block)
        else
          yield self
        end
      end

      self
    end

    # If you assign a delivery handler, mail will call :deliver_mail on the
    # object you assign to delivery_handler, it will pass itself as the
    # single argument.
    #
    # If you define a delivery_handler, then you are responsible for the
    # following actions in the delivery cycle:
    #
    # * Appending the mail object to Mail.deliveries as you see fit.
    # * Checking the mail.perform_deliveries flag to decide if you should
    #   actually call :deliver! the mail object or not.
    # * Checking the mail.raise_delivery_errors flag to decide if you
    #   should raise delivery errors if they occur.
    # * Actually calling :deliver! (with the bang) on the mail object to
    #   get it to deliver itself.
    #
    # A simplest implementation of a delivery_handler would be
    #
    #   class MyObject
    #
    #     def initialize
    #       @mail = Mail.new('To: mikel@test.lindsaar.net')
    #       @mail.delivery_handler = self
    #     end
    #
    #     attr_accessor :mail
    #
    #     def deliver_mail(mail)
    #       yield
    #     end
    #   end
    #
    # Then doing:
    #
    #   obj = MyObject.new
    #   obj.mail.deliver
    #
    # Would cause Mail to call obj.deliver_mail passing itself as a parameter,
    # which then can just yield and let Mail do its own private do_delivery
    # method.
    attr_accessor :delivery_handler

    # If set to false, mail will go through the motions of doing a delivery,
    # but not actually call the delivery method or append the mail object to
    # the Mail.deliveries collection.  Useful for testing.
    #
    #   Mail.deliveries.size #=> 0
    #   mail.delivery_method :smtp
    #   mail.perform_deliveries = false
    #   mail.deliver                        # Mail::SMTP not called here
    #   Mail.deliveries.size #=> 0
    #
    # If you want to test and query the Mail.deliveries collection to see what
    # mail you sent, you should set perform_deliveries to true and use
    # the :test mail delivery_method:
    #
    #   Mail.deliveries.size #=> 0
    #   mail.delivery_method :test
    #   mail.perform_deliveries = true
    #   mail.deliver
    #   Mail.deliveries.size #=> 1
    #
    # This setting is ignored by mail (though still available as a flag) if you
    # define a delivery_handler
    attr_accessor :perform_deliveries

    # If set to false, mail will silently catch and ignore any exceptions
    # raised through attempting to deliver an email.
    #
    # This setting is ignored by mail (though still available as a flag) if you
    # define a delivery_handler
    attr_accessor :raise_delivery_errors

    def self.default_charset; @@default_charset; end
    def self.default_charset=(charset); @@default_charset = charset; end
    self.default_charset = 'UTF-8'

    def register_for_delivery_notification(observer)
      warn("Message#register_for_delivery_notification is deprecated, please call Mail.register_observer instead")
      Mail.register_observer(observer)
    end

    def inform_observers
      Mail.inform_observers(self)
    end

    def inform_interceptors
      Mail.inform_interceptors(self)
    end

    # Delivers a mail object.
    #
    # Examples:
    #
    #  mail = Mail.read('file.eml')
    #  mail.deliver
    def deliver
      inform_interceptors
      if delivery_handler
        delivery_handler.deliver_mail(self) { do_delivery }
      else
        do_delivery
      end
      inform_observers
      self
    end

    # This method bypasses checking perform_deliveries and raise_delivery_errors,
    # so use with caution.
    #
    # It still however fires off the interceptors and calls the observers callbacks if they are defined.
    #
    # Returns self
    def deliver!
      inform_interceptors
      response = delivery_method.deliver!(self)
      inform_observers
      delivery_method.settings[:return_response] ? response : self
    end

    def delivery_method(method = nil, settings = {})
      unless method
        @delivery_method
      else
        @delivery_method = Configuration.instance.lookup_delivery_method(method).new(settings)
      end
    end

    def reply(*args, &block)
      self.class.new.tap do |reply|
        if message_id
          bracketed_message_id = "<#{message_id}>"
          reply.in_reply_to = bracketed_message_id
          if !references.nil?
            refs = [references].flatten.map { |r| "<#{r}>" }
            refs << bracketed_message_id
            reply.references = refs.join(' ')
          elsif !in_reply_to.nil? && !in_reply_to.kind_of?(Array)
            reply.references = "<#{in_reply_to}> #{bracketed_message_id}"
          end
          reply.references ||= bracketed_message_id
        end
        if subject
          reply.subject = subject =~ /^Re:/i ? subject : "RE: #{subject}"
        end
        if reply_to || from
          reply.to = self[reply_to ? :reply_to : :from].to_s
        end
        if to
          reply.from = self[:to].formatted.first.to_s
        end

        unless args.empty?
          if args.flatten.first.respond_to?(:each_pair)
            reply.send(:init_with_hash, args.flatten.first)
          else
            reply.send(:init_with_string, args.flatten[0].to_s.strip)
          end
        end

        if block_given?
          reply.instance_eval(&block)
        end
      end
    end

    # Provides the operator needed for sort et al.
    #
    # Compares this mail object with another mail object, this is done by date, so an
    # email that is older than another will appear first.
    #
    # Example:
    #
    #  mail1 = Mail.new do
    #    date(Time.now)
    #  end
    #  mail2 = Mail.new do
    #    date(Time.now - 86400) # 1 day older
    #  end
    #  [mail2, mail1].sort #=> [mail2, mail1]
    def <=>(other)
      if other.nil?
        1
      else
        self.date <=> other.date
      end
    end

    # Two emails are the same if they have the same fields and body contents. One
    # gotcha here is that Mail will insert Message-IDs when calling encoded, so doing
    # mail1.encoded == mail2.encoded is most probably not going to return what you think
    # as the assigned Message-IDs by Mail (if not already defined as the same) will ensure
    # that the two objects are unique, and this comparison will ALWAYS return false.
    #
    # So the == operator has been defined like so:  Two messages are the same if they have
    # the same content, ignoring the Message-ID field, unless BOTH emails have a defined and
    # different Message-ID value, then they are false.
    #
    # So, in practice the == operator works like this:
    #
    #  m1 = Mail.new("Subject: Hello\r\n\r\nHello")
    #  m2 = Mail.new("Subject: Hello\r\n\r\nHello")
    #  m1 == m2 #=> true
    #
    #  m1 = Mail.new("Subject: Hello\r\n\r\nHello")
    #  m2 = Mail.new("Message-ID: <1234@test>\r\nSubject: Hello\r\n\r\nHello")
    #  m1 == m2 #=> true
    #
    #  m1 = Mail.new("Message-ID: <1234@test>\r\nSubject: Hello\r\n\r\nHello")
    #  m2 = Mail.new("Subject: Hello\r\n\r\nHello")
    #  m1 == m2 #=> true
    #
    #  m1 = Mail.new("Message-ID: <1234@test>\r\nSubject: Hello\r\n\r\nHello")
    #  m2 = Mail.new("Message-ID: <1234@test>\r\nSubject: Hello\r\n\r\nHello")
    #  m1 == m2 #=> true
    #
    #  m1 = Mail.new("Message-ID: <1234@test>\r\nSubject: Hello\r\n\r\nHello")
    #  m2 = Mail.new("Message-ID: <DIFFERENT@test>\r\nSubject: Hello\r\n\r\nHello")
    #  m1 == m2 #=> false
    def ==(other)
      return false unless other.respond_to?(:encoded)

      if self.message_id && other.message_id
        self.encoded == other.encoded
      else
        dup.tap { |m| m.message_id = '<temp@test>' }.encoded ==
          other.dup.tap { |m| m.message_id = '<temp@test>' }.encoded
      end
    end

    def initialize_copy(original)
      super
      @header = @header.dup
    end

    # Provides access to the raw source of the message as it was when it
    # was instantiated. This is set at initialization and so is untouched
    # by the parsers or decoder / encoders
    #
    # Example:
    #
    #  mail = Mail.new('This is an invalid email message')
    #  mail.raw_source #=> "This is an invalid email message"
    def raw_source
      @raw_source
    end

    # Sets the envelope from for the email
    def set_envelope( val )
      @raw_envelope = val
      @envelope = Mail::Envelope.new( val )
    end

    # The raw_envelope is the From mikel@test.lindsaar.net Mon May  2 16:07:05 2009
    # type field that you can see at the top of any email that has come
    # from a mailbox
    def raw_envelope
      @raw_envelope
    end

    def envelope_from
      @envelope ? @envelope.from : nil
    end

    def envelope_date
      @envelope ? @envelope.date : nil
    end

    # Sets the header of the message object.
    #
    # Example:
    #
    #  mail.header = 'To: mikel@test.lindsaar.net\r\nFrom: Bob@bob.com'
    #  mail.header #=> <#Mail::Header
    def header=(value)
      @header = Mail::Header.new(value, charset)
    end

    # Returns the header object of the message object. Or, if passed
    # a parameter sets the value.
    #
    # Example:
    #
    #  mail = Mail::Message.new('To: mikel\r\nFrom: you')
    #  mail.header #=> #<Mail::Header:0x13ce14 @raw_source="To: mikel\r\nFr...
    #
    #  mail.header #=> nil
    #  mail.header 'To: mikel\r\nFrom: you'
    #  mail.header #=> #<Mail::Header:0x13ce14 @raw_source="To: mikel\r\nFr...
    def header(value = nil)
      value ? self.header = value : @header
    end

    # Provides a way to set custom headers, by passing in a hash
    def headers(hash = {})
      hash.each_pair do |k,v|
        header[k] = v
      end
    end

    # Returns a list of parser errors on the header, each field that had an error
    # will be reparsed as an unstructured field to preserve the data inside, but
    # will not be used for further processing.
    #
    # It returns a nested array of [field_name, value, original_error_message]
    # per error found.
    #
    # Example:
    #
    #  message = Mail.new("Content-Transfer-Encoding: weirdo\r\n")
    #  message.errors.size #=> 1
    #  message.errors.first[0] #=> "Content-Transfer-Encoding"
    #  message.errors.first[1] #=> "weirdo"
    #  message.errors.first[3] #=> <The original error message exception>
    #
    # This is a good first defence on detecting spam by the way.  Some spammers send
    # invalid emails to try and get email parsers to give up parsing them.
    def errors
      header.errors
    end

    # Returns the Bcc value of the mail object as an array of strings of
    # address specs.
    #
    # Example:
    #
    #  mail.bcc = 'Mikel <mikel@test.lindsaar.net>'
    #  mail.bcc #=> ['mikel@test.lindsaar.net']
    #  mail.bcc = 'Mikel <mikel@test.lindsaar.net>, ada@test.lindsaar.net'
    #  mail.bcc #=> ['mikel@test.lindsaar.net', 'ada@test.lindsaar.net']
    #
    # Also allows you to set the value by passing a value as a parameter
    #
    # Example:
    #
    #  mail.bcc 'Mikel <mikel@test.lindsaar.net>'
    #  mail.bcc #=> ['mikel@test.lindsaar.net']
    #
    # Additionally, you can append new addresses to the returned Array like
    # object.
    #
    # Example:
    #
    #  mail.bcc 'Mikel <mikel@test.lindsaar.net>'
    #  mail.bcc << 'ada@test.lindsaar.net'
    #  mail.bcc #=> ['mikel@test.lindsaar.net', 'ada@test.lindsaar.net']
    def bcc( val = nil )
      default :bcc, val
    end

    # Sets the Bcc value of the mail object, pass in a string of the field
    #
    # Example:
    #
    #  mail.bcc = 'Mikel <mikel@test.lindsaar.net>'
    #  mail.bcc #=> ['mikel@test.lindsaar.net']
    #  mail.bcc = 'Mikel <mikel@test.lindsaar.net>, ada@test.lindsaar.net'
    #  mail.bcc #=> ['mikel@test.lindsaar.net', 'ada@test.lindsaar.net']
    def bcc=( val )
      header[:bcc] = val
    end

    # Returns the Cc value of the mail object as an array of strings of
    # address specs.
    #
    # Example:
    #
    #  mail.cc = 'Mikel <mikel@test.lindsaar.net>'
    #  mail.cc #=> ['mikel@test.lindsaar.net']
    #  mail.cc = 'Mikel <mikel@test.lindsaar.net>, ada@test.lindsaar.net'
    #  mail.cc #=> ['mikel@test.lindsaar.net', 'ada@test.lindsaar.net']
    #
    # Also allows you to set the value by passing a value as a parameter
    #
    # Example:
    #
    #  mail.cc 'Mikel <mikel@test.lindsaar.net>'
    #  mail.cc #=> ['mikel@test.lindsaar.net']
    #
    # Additionally, you can append new addresses to the returned Array like
    # object.
    #
    # Example:
    #
    #  mail.cc 'Mikel <mikel@test.lindsaar.net>'
    #  mail.cc << 'ada@test.lindsaar.net'
    #  mail.cc #=> ['mikel@test.lindsaar.net', 'ada@test.lindsaar.net']
    def cc( val = nil )
      default :cc, val
    end

    # Sets the Cc value of the mail object, pass in a string of the field
    #
    # Example:
    #
    #  mail.cc = 'Mikel <mikel@test.lindsaar.net>'
    #  mail.cc #=> ['mikel@test.lindsaar.net']
    #  mail.cc = 'Mikel <mikel@test.lindsaar.net>, ada@test.lindsaar.net'
    #  mail.cc #=> ['mikel@test.lindsaar.net', 'ada@test.lindsaar.net']
    def cc=( val )
      header[:cc] = val
    end

    def comments( val = nil )
      default :comments, val
    end

    def comments=( val )
      header[:comments] = val
    end

    def content_description( val = nil )
      default :content_description, val
    end

    def content_description=( val )
      header[:content_description] = val
    end

    def content_disposition( val = nil )
      default :content_disposition, val
    end

    def content_disposition=( val )
      header[:content_disposition] = val
    end

    def content_id( val = nil )
      default :content_id, val
    end

    def content_id=( val )
      header[:content_id] = val
    end

    def content_location( val = nil )
      default :content_location, val
    end

    def content_location=( val )
      header[:content_location] = val
    end

    def content_transfer_encoding( val = nil )
      default :content_transfer_encoding, val
    end

    def content_transfer_encoding=( val )
      header[:content_transfer_encoding] = val
    end

    def content_type( val = nil )
      default :content_type, val
    end

    def content_type=( val )
      header[:content_type] = val
    end

    def date( val = nil )
      default :date, val
    end

    def date=( val )
      header[:date] = val
    end

    def transport_encoding( val = nil)
      if val
        self.transport_encoding = val
      else
        @transport_encoding
      end
    end

    def transport_encoding=( val )
      @transport_encoding = Mail::Encodings.get_encoding(val)
    end

    # Returns the From value of the mail object as an array of strings of
    # address specs.
    #
    # Example:
    #
    #  mail.from = 'Mikel <mikel@test.lindsaar.net>'
    #  mail.from #=> ['mikel@test.lindsaar.net']
    #  mail.from = 'Mikel <mikel@test.lindsaar.net>, ada@test.lindsaar.net'
    #  mail.from #=> ['mikel@test.lindsaar.net', 'ada@test.lindsaar.net']
    #
    # Also allows you to set the value by passing a value as a parameter
    #
    # Example:
    #
    #  mail.from 'Mikel <mikel@test.lindsaar.net>'
    #  mail.from #=> ['mikel@test.lindsaar.net']
    #
    # Additionally, you can append new addresses to the returned Array like
    # object.
    #
    # Example:
    #
    #  mail.from 'Mikel <mikel@test.lindsaar.net>'
    #  mail.from << 'ada@test.lindsaar.net'
    #  mail.from #=> ['mikel@test.lindsaar.net', 'ada@test.lindsaar.net']
    def from( val = nil )
      default :from, val
    end

    # Sets the From value of the mail object, pass in a string of the field
    #
    # Example:
    #
    #  mail.from = 'Mikel <mikel@test.lindsaar.net>'
    #  mail.from #=> ['mikel@test.lindsaar.net']
    #  mail.from = 'Mikel <mikel@test.lindsaar.net>, ada@test.lindsaar.net'
    #  mail.from #=> ['mikel@test.lindsaar.net', 'ada@test.lindsaar.net']
    def from=( val )
      header[:from] = val
    end

    def in_reply_to( val = nil )
      default :in_reply_to, val
    end

    def in_reply_to=( val )
      header[:in_reply_to] = val
    end

    def keywords( val = nil )
      default :keywords, val
    end

    def keywords=( val )
      header[:keywords] = val
    end

    # Returns the Message-ID of the mail object.  Note, per RFC 2822 the Message ID
    # consists of what is INSIDE the < > usually seen in the mail header, so this method
    # will return only what is inside.
    #
    # Example:
    #
    #  mail.message_id = '<1234@message.id>'
    #  mail.message_id #=> '1234@message.id'
    #
    # Also allows you to set the Message-ID by passing a string as a parameter
    #
    #  mail.message_id '<1234@message.id>'
    #  mail.message_id #=> '1234@message.id'
    def message_id( val = nil )
      default :message_id, val
    end

    # Sets the Message-ID. Note, per RFC 2822 the Message ID consists of what is INSIDE
    # the < > usually seen in the mail header, so this method will return only what is inside.
    #
    #  mail.message_id = '<1234@message.id>'
    #  mail.message_id #=> '1234@message.id'
    def message_id=( val )
      header[:message_id] = val
    end

    # Returns the MIME version of the email as a string
    #
    # Example:
    #
    #  mail.mime_version = '1.0'
    #  mail.mime_version #=> '1.0'
    #
    # Also allows you to set the MIME version by passing a string as a parameter.
    #
    # Example:
    #
    #  mail.mime_version '1.0'
    #  mail.mime_version #=> '1.0'
    def mime_version( val = nil )
      default :mime_version, val
    end

    # Sets the MIME version of the email by accepting a string
    #
    # Example:
    #
    #  mail.mime_version = '1.0'
    #  mail.mime_version #=> '1.0'
    def mime_version=( val )
      header[:mime_version] = val
    end

    def received( val = nil )
      if val
        header[:received] = val
      else
        header[:received]
      end
    end

    def received=( val )
      header[:received] = val
    end

    def references( val = nil )
      default :references, val
    end

    def references=( val )
      header[:references] = val
    end

    # Returns the Reply-To value of the mail object as an array of strings of
    # address specs.
    #
    # Example:
    #
    #  mail.reply_to = 'Mikel <mikel@test.lindsaar.net>'
    #  mail.reply_to #=> ['mikel@test.lindsaar.net']
    #  mail.reply_to = 'Mikel <mikel@test.lindsaar.net>, ada@test.lindsaar.net'
    #  mail.reply_to #=> ['mikel@test.lindsaar.net', 'ada@test.lindsaar.net']
    #
    # Also allows you to set the value by passing a value as a parameter
    #
    # Example:
    #
    #  mail.reply_to 'Mikel <mikel@test.lindsaar.net>'
    #  mail.reply_to #=> ['mikel@test.lindsaar.net']
    #
    # Additionally, you can append new addresses to the returned Array like
    # object.
    #
    # Example:
    #
    #  mail.reply_to 'Mikel <mikel@test.lindsaar.net>'
    #  mail.reply_to << 'ada@test.lindsaar.net'
    #  mail.reply_to #=> ['mikel@test.lindsaar.net', 'ada@test.lindsaar.net']
    def reply_to( val = nil )
      default :reply_to, val
    end

    # Sets the Reply-To value of the mail object, pass in a string of the field
    #
    # Example:
    #
    #  mail.reply_to = 'Mikel <mikel@test.lindsaar.net>'
    #  mail.reply_to #=> ['mikel@test.lindsaar.net']
    #  mail.reply_to = 'Mikel <mikel@test.lindsaar.net>, ada@test.lindsaar.net'
    #  mail.reply_to #=> ['mikel@test.lindsaar.net', 'ada@test.lindsaar.net']
    def reply_to=( val )
      header[:reply_to] = val
    end

    # Returns the Resent-Bcc value of the mail object as an array of strings of
    # address specs.
    #
    # Example:
    #
    #  mail.resent_bcc = 'Mikel <mikel@test.lindsaar.net>'
    #  mail.resent_bcc #=> ['mikel@test.lindsaar.net']
    #  mail.resent_bcc = 'Mikel <mikel@test.lindsaar.net>, ada@test.lindsaar.net'
    #  mail.resent_bcc #=> ['mikel@test.lindsaar.net', 'ada@test.lindsaar.net']
    #
    # Also allows you to set the value by passing a value as a parameter
    #
    # Example:
    #
    #  mail.resent_bcc 'Mikel <mikel@test.lindsaar.net>'
    #  mail.resent_bcc #=> ['mikel@test.lindsaar.net']
    #
    # Additionally, you can append new addresses to the returned Array like
    # object.
    #
    # Example:
    #
    #  mail.resent_bcc 'Mikel <mikel@test.lindsaar.net>'
    #  mail.resent_bcc << 'ada@test.lindsaar.net'
    #  mail.resent_bcc #=> ['mikel@test.lindsaar.net', 'ada@test.lindsaar.net']
    def resent_bcc( val = nil )
      default :resent_bcc, val
    end

    # Sets the Resent-Bcc value of the mail object, pass in a string of the field
    #
    # Example:
    #
    #  mail.resent_bcc = 'Mikel <mikel@test.lindsaar.net>'
    #  mail.resent_bcc #=> ['mikel@test.lindsaar.net']
    #  mail.resent_bcc = 'Mikel <mikel@test.lindsaar.net>, ada@test.lindsaar.net'
    #  mail.resent_bcc #=> ['mikel@test.lindsaar.net', 'ada@test.lindsaar.net']
    def resent_bcc=( val )
      header[:resent_bcc] = val
    end

    # Returns the Resent-Cc value of the mail object as an array of strings of
    # address specs.
    #
    # Example:
    #
    #  mail.resent_cc = 'Mikel <mikel@test.lindsaar.net>'
    #  mail.resent_cc #=> ['mikel@test.lindsaar.net']
    #  mail.resent_cc = 'Mikel <mikel@test.lindsaar.net>, ada@test.lindsaar.net'
    #  mail.resent_cc #=> ['mikel@test.lindsaar.net', 'ada@test.lindsaar.net']
    #
    # Also allows you to set the value by passing a value as a parameter
    #
    # Example:
    #
    #  mail.resent_cc 'Mikel <mikel@test.lindsaar.net>'
    #  mail.resent_cc #=> ['mikel@test.lindsaar.net']
    #
    # Additionally, you can append new addresses to the returned Array like
    # object.
    #
    # Example:
    #
    #  mail.resent_cc 'Mikel <mikel@test.lindsaar.net>'
    #  mail.resent_cc << 'ada@test.lindsaar.net'
    #  mail.resent_cc #=> ['mikel@test.lindsaar.net', 'ada@test.lindsaar.net']
    def resent_cc( val = nil )
      default :resent_cc, val
    end

    # Sets the Resent-Cc value of the mail object, pass in a string of the field
    #
    # Example:
    #
    #  mail.resent_cc = 'Mikel <mikel@test.lindsaar.net>'
    #  mail.resent_cc #=> ['mikel@test.lindsaar.net']
    #  mail.resent_cc = 'Mikel <mikel@test.lindsaar.net>, ada@test.lindsaar.net'
    #  mail.resent_cc #=> ['mikel@test.lindsaar.net', 'ada@test.lindsaar.net']
    def resent_cc=( val )
      header[:resent_cc] = val
    end

    def resent_date( val = nil )
      default :resent_date, val
    end

    def resent_date=( val )
      header[:resent_date] = val
    end

    # Returns the Resent-From value of the mail object as an array of strings of
    # address specs.
    #
    # Example:
    #
    #  mail.resent_from = 'Mikel <mikel@test.lindsaar.net>'
    #  mail.resent_from #=> ['mikel@test.lindsaar.net']
    #  mail.resent_from = 'Mikel <mikel@test.lindsaar.net>, ada@test.lindsaar.net'
    #  mail.resent_from #=> ['mikel@test.lindsaar.net', 'ada@test.lindsaar.net']
    #
    # Also allows you to set the value by passing a value as a parameter
    #
    # Example:
    #
    #  mail.resent_from ['Mikel <mikel@test.lindsaar.net>']
    #  mail.resent_from #=> 'mikel@test.lindsaar.net'
    #
    # Additionally, you can append new addresses to the returned Array like
    # object.
    #
    # Example:
    #
    #  mail.resent_from 'Mikel <mikel@test.lindsaar.net>'
    #  mail.resent_from << 'ada@test.lindsaar.net'
    #  mail.resent_from #=> ['mikel@test.lindsaar.net', 'ada@test.lindsaar.net']
    def resent_from( val = nil )
      default :resent_from, val
    end

    # Sets the Resent-From value of the mail object, pass in a string of the field
    #
    # Example:
    #
    #  mail.resent_from = 'Mikel <mikel@test.lindsaar.net>'
    #  mail.resent_from #=> ['mikel@test.lindsaar.net']
    #  mail.resent_from = 'Mikel <mikel@test.lindsaar.net>, ada@test.lindsaar.net'
    #  mail.resent_from #=> ['mikel@test.lindsaar.net', 'ada@test.lindsaar.net']
    def resent_from=( val )
      header[:resent_from] = val
    end

    def resent_message_id( val = nil )
      default :resent_message_id, val
    end

    def resent_message_id=( val )
      header[:resent_message_id] = val
    end

    # Returns the Resent-Sender value of the mail object, as a single string of an address
    # spec.  A sender per RFC 2822 must be a single address, so you can not append to
    # this address.
    #
    # Example:
    #
    #  mail.resent_sender = 'Mikel <mikel@test.lindsaar.net>'
    #  mail.resent_sender #=> 'mikel@test.lindsaar.net'
    #
    # Also allows you to set the value by passing a value as a parameter
    #
    # Example:
    #
    #  mail.resent_sender 'Mikel <mikel@test.lindsaar.net>'
    #  mail.resent_sender #=> 'mikel@test.lindsaar.net'
    def resent_sender( val = nil )
      default :resent_sender, val
    end

    # Sets the Resent-Sender value of the mail object, pass in a string of the field
    #
    # Example:
    #
    #  mail.resent_sender = 'Mikel <mikel@test.lindsaar.net>'
    #  mail.resent_sender #=> 'mikel@test.lindsaar.net'
    def resent_sender=( val )
      header[:resent_sender] = val
    end

    # Returns the Resent-To value of the mail object as an array of strings of
    # address specs.
    #
    # Example:
    #
    #  mail.resent_to = 'Mikel <mikel@test.lindsaar.net>'
    #  mail.resent_to #=> ['mikel@test.lindsaar.net']
    #  mail.resent_to = 'Mikel <mikel@test.lindsaar.net>, ada@test.lindsaar.net'
    #  mail.resent_to #=> ['mikel@test.lindsaar.net', 'ada@test.lindsaar.net']
    #
    # Also allows you to set the value by passing a value as a parameter
    #
    # Example:
    #
    #  mail.resent_to 'Mikel <mikel@test.lindsaar.net>'
    #  mail.resent_to #=> ['mikel@test.lindsaar.net']
    #
    # Additionally, you can append new addresses to the returned Array like
    # object.
    #
    # Example:
    #
    #  mail.resent_to 'Mikel <mikel@test.lindsaar.net>'
    #  mail.resent_to << 'ada@test.lindsaar.net'
    #  mail.resent_to #=> ['mikel@test.lindsaar.net', 'ada@test.lindsaar.net']
    def resent_to( val = nil )
      default :resent_to, val
    end

    # Sets the Resent-To value of the mail object, pass in a string of the field
    #
    # Example:
    #
    #  mail.resent_to = 'Mikel <mikel@test.lindsaar.net>'
    #  mail.resent_to #=> ['mikel@test.lindsaar.net']
    #  mail.resent_to = 'Mikel <mikel@test.lindsaar.net>, ada@test.lindsaar.net'
    #  mail.resent_to #=> ['mikel@test.lindsaar.net', 'ada@test.lindsaar.net']
    def resent_to=( val )
      header[:resent_to] = val
    end

    # Returns the return path of the mail object, or sets it if you pass a string
    def return_path( val = nil )
      default :return_path, val
    end

    # Sets the return path of the object
    def return_path=( val )
      header[:return_path] = val
    end

    # Returns the Sender value of the mail object, as a single string of an address
    # spec.  A sender per RFC 2822 must be a single address.
    #
    # Example:
    #
    #  mail.sender = 'Mikel <mikel@test.lindsaar.net>'
    #  mail.sender #=> 'mikel@test.lindsaar.net'
    #
    # Also allows you to set the value by passing a value as a parameter
    #
    # Example:
    #
    #  mail.sender 'Mikel <mikel@test.lindsaar.net>'
    #  mail.sender #=> 'mikel@test.lindsaar.net'
    def sender( val = nil )
      default :sender, val
    end

    # Sets the Sender value of the mail object, pass in a string of the field
    #
    # Example:
    #
    #  mail.sender = 'Mikel <mikel@test.lindsaar.net>'
    #  mail.sender #=> 'mikel@test.lindsaar.net'
    def sender=( val )
      header[:sender] = val
    end

    # Returns the SMTP Envelope From value of the mail object, as a single
    # string of an address spec.
    #
    # Defaults to Return-Path, Sender, or the first From address.
    #
    # Example:
    #
    #  mail.smtp_envelope_from = 'Mikel <mikel@test.lindsaar.net>'
    #  mail.smtp_envelope_from #=> 'mikel@test.lindsaar.net'
    #
    # Also allows you to set the value by passing a value as a parameter
    #
    # Example:
    #
    #  mail.smtp_envelope_from 'Mikel <mikel@test.lindsaar.net>'
    #  mail.smtp_envelope_from #=> 'mikel@test.lindsaar.net'
    def smtp_envelope_from( val = nil )
      if val
        self.smtp_envelope_from = val
      else
        @smtp_envelope_from || return_path || sender || from_addrs.first
      end
    end

    # Sets the From address on the SMTP Envelope.
    #
    # Example:
    #
    #  mail.smtp_envelope_from = 'Mikel <mikel@test.lindsaar.net>'
    #  mail.smtp_envelope_from #=> 'mikel@test.lindsaar.net'
    def smtp_envelope_from=( val )
      @smtp_envelope_from = val
    end

    # Returns the SMTP Envelope To value of the mail object.
    #
    # Defaults to #destinations: To, Cc, and Bcc addresses.
    #
    # Example:
    #
    #  mail.smtp_envelope_to = 'Mikel <mikel@test.lindsaar.net>'
    #  mail.smtp_envelope_to #=> 'mikel@test.lindsaar.net'
    #
    # Also allows you to set the value by passing a value as a parameter
    #
    # Example:
    #
    #  mail.smtp_envelope_to ['Mikel <mikel@test.lindsaar.net>', 'Lindsaar <lindsaar@test.lindsaar.net>']
    #  mail.smtp_envelope_to #=> ['mikel@test.lindsaar.net', 'lindsaar@test.lindsaar.net']
    def smtp_envelope_to( val = nil )
      if val
        self.smtp_envelope_to = val
      else
        @smtp_envelope_to || destinations
      end
    end

    # Sets the To addresses on the SMTP Envelope.
    #
    # Example:
    #
    #  mail.smtp_envelope_to = 'Mikel <mikel@test.lindsaar.net>'
    #  mail.smtp_envelope_to #=> 'mikel@test.lindsaar.net'
    #
    #  mail.smtp_envelope_to = ['Mikel <mikel@test.lindsaar.net>', 'Lindsaar <lindsaar@test.lindsaar.net>']
    #  mail.smtp_envelope_to #=> ['mikel@test.lindsaar.net', 'lindsaar@test.lindsaar.net']
    def smtp_envelope_to=( val )
      @smtp_envelope_to =
        case val
        when Array, NilClass
          val
        else
          [val]
        end
    end

    # Returns the decoded value of the subject field, as a single string.
    #
    # Example:
    #
    #  mail.subject = "G'Day mate"
    #  mail.subject #=> "G'Day mate"
    #  mail.subject = '=?UTF-8?Q?This_is_=E3=81=82_string?='
    #  mail.subject #=> "This is あ string"
    #
    # Also allows you to set the value by passing a value as a parameter
    #
    # Example:
    #
    #  mail.subject "G'Day mate"
    #  mail.subject #=> "G'Day mate"
    def subject( val = nil )
      default :subject, val
    end

    # Sets the Subject value of the mail object, pass in a string of the field
    #
    # Example:
    #
    #  mail.subject = '=?UTF-8?Q?This_is_=E3=81=82_string?='
    #  mail.subject #=> "This is あ string"
    def subject=( val )
      header[:subject] = val
    end

    # Returns the To value of the mail object as an array of strings of
    # address specs.
    #
    # Example:
    #
    #  mail.to = 'Mikel <mikel@test.lindsaar.net>'
    #  mail.to #=> ['mikel@test.lindsaar.net']
    #  mail.to = 'Mikel <mikel@test.lindsaar.net>, ada@test.lindsaar.net'
    #  mail.to #=> ['mikel@test.lindsaar.net', 'ada@test.lindsaar.net']
    #
    # Also allows you to set the value by passing a value as a parameter
    #
    # Example:
    #
    #  mail.to 'Mikel <mikel@test.lindsaar.net>'
    #  mail.to #=> ['mikel@test.lindsaar.net']
    #
    # Additionally, you can append new addresses to the returned Array like
    # object.
    #
    # Example:
    #
    #  mail.to 'Mikel <mikel@test.lindsaar.net>'
    #  mail.to << 'ada@test.lindsaar.net'
    #  mail.to #=> ['mikel@test.lindsaar.net', 'ada@test.lindsaar.net']
    def to( val = nil )
      default :to, val
    end

    # Sets the To value of the mail object, pass in a string of the field
    #
    # Example:
    #
    #  mail.to = 'Mikel <mikel@test.lindsaar.net>'
    #  mail.to #=> ['mikel@test.lindsaar.net']
    #  mail.to = 'Mikel <mikel@test.lindsaar.net>, ada@test.lindsaar.net'
    #  mail.to #=> ['mikel@test.lindsaar.net', 'ada@test.lindsaar.net']
    def to=( val )
      header[:to] = val
    end

    # Returns the default value of the field requested as a symbol.
    #
    # Each header field has a :default method which returns the most common use case for
    # that field, for example, the date field types will return a DateTime object when
    # sent :default, the subject, or unstructured fields will return a decoded string of
    # their value, the address field types will return a single addr_spec or an array of
    # addr_specs if there is more than one.
    def default( sym, val = nil )
      if val
        header[sym] = val
      elsif field = header[sym]
        field.default
      end
    end

    # Sets the body object of the message object.
    #
    # Example:
    #
    #  mail.body = 'This is the body'
    #  mail.body #=> #<Mail::Body:0x13919c @raw_source="This is the bo...
    #
    # You can also reset the body of an Message object by setting body to nil
    #
    # Example:
    #
    #  mail.body = 'this is the body'
    #  mail.body.encoded #=> 'this is the body'
    #  mail.body = nil
    #  mail.body.encoded #=> ''
    #
    # If you try and set the body of an email that is a multipart email, then instead
    # of deleting all the parts of your email, mail will add a text/plain part to
    # your email:
    #
    #  mail.add_file 'somefilename.png'
    #  mail.parts.length #=> 1
    #  mail.body = "This is a body"
    #  mail.parts.length #=> 2
    #  mail.parts.last.content_type.content_type #=> 'This is a body'
    def body=(value)
      body_lazy(value)
    end

    # Returns the body of the message object. Or, if passed
    # a parameter sets the value.
    #
    # Example:
    #
    #  mail = Mail::Message.new('To: mikel\r\n\r\nThis is the body')
    #  mail.body #=> #<Mail::Body:0x13919c @raw_source="This is the bo...
    #
    #  mail.body 'This is another body'
    #  mail.body #=> #<Mail::Body:0x13919c @raw_source="This is anothe...
    def body(value = nil)
      if value
        self.body = value
      else
        process_body_raw if @body_raw
        @body
      end
    end

    def body_encoding(value = nil)
      if value.nil?
        body.encoding
      else
        body.encoding = value
      end
    end

    def body_encoding=(value)
      body.encoding = value
    end

    # Returns the list of addresses this message should be sent to by
    # collecting the addresses off the to, cc and bcc fields.
    #
    # Example:
    #
    #  mail.to = 'mikel@test.lindsaar.net'
    #  mail.cc = 'sam@test.lindsaar.net'
    #  mail.bcc = 'bob@test.lindsaar.net'
    #  mail.destinations.length #=> 3
    #  mail.destinations.first #=> 'mikel@test.lindsaar.net'
    def destinations
      [to_addrs, cc_addrs, bcc_addrs].compact.flatten
    end

    # Returns an array of addresses (the encoded value) in the From field,
    # if no From field, returns an empty array
    def from_addrs
      from ? [from].flatten : []
    end

    # Returns an array of addresses (the encoded value) in the To field,
    # if no To field, returns an empty array
    def to_addrs
      to ? [to].flatten : []
    end

    # Returns an array of addresses (the encoded value) in the Cc field,
    # if no Cc field, returns an empty array
    def cc_addrs
      cc ? [cc].flatten : []
    end

    # Returns an array of addresses (the encoded value) in the Bcc field,
    # if no Bcc field, returns an empty array
    def bcc_addrs
      bcc ? [bcc].flatten : []
    end

    # Allows you to add an arbitrary header
    #
    # Example:
    #
    #  mail['foo'] = '1234'
    #  mail['foo'].to_s #=> '1234'
    def []=(name, value)
      if name.to_s == 'body'
        self.body = value
      elsif name.to_s =~ /content[-_]type/i
        header[name] = value
      elsif name.to_s == 'charset'
        self.charset = value
      else
        header[name] = value
      end
    end

    # Allows you to read an arbitrary header
    #
    # Example:
    #
    #  mail['foo'] = '1234'
    #  mail['foo'].to_s #=> '1234'
    def [](name)
      header[underscoreize(name)]
    end

    # Method Missing in this implementation allows you to set any of the
    # standard fields directly as you would the "to", "subject" etc.
    #
    # Those fields used most often (to, subject et al) are given their
    # own method for ease of documentation and also to avoid the hook
    # call to method missing.
    #
    # This will only catch the known fields listed in:
    #
    #  Mail::Field::KNOWN_FIELDS
    #
    # as per RFC 2822, any ruby string or method name could pretty much
    # be a field name, so we don't want to just catch ANYTHING sent to
    # a message object and interpret it as a header.
    #
    # This method provides all three types of header call to set, read
    # and explicitly set with the = operator
    #
    # Examples:
    #
    #  mail.comments = 'These are some comments'
    #  mail.comments #=> 'These are some comments'
    #
    #  mail.comments 'These are other comments'
    #  mail.comments #=> 'These are other comments'
    #
    #
    #  mail.date = 'Tue, 1 Jul 2003 10:52:37 +0200'
    #  mail.date.to_s #=> 'Tue, 1 Jul 2003 10:52:37 +0200'
    #
    #  mail.date 'Tue, 1 Jul 2003 10:52:37 +0200'
    #  mail.date.to_s #=> 'Tue, 1 Jul 2003 10:52:37 +0200'
    #
    #
    #  mail.resent_msg_id = '<1234@resent_msg_id.lindsaar.net>'
    #  mail.resent_msg_id #=> '<1234@resent_msg_id.lindsaar.net>'
    #
    #  mail.resent_msg_id '<4567@resent_msg_id.lindsaar.net>'
    #  mail.resent_msg_id #=> '<4567@resent_msg_id.lindsaar.net>'
    def method_missing(name, *args, &block)
      #:nodoc:
      # Only take the structured fields, as we could take _anything_ really
      # as it could become an optional field... "but therin lies the dark side"
      field_name = underscoreize(name).chomp("=")
      if Mail::Field::KNOWN_FIELDS.include?(field_name)
        if args.empty?
          header[field_name]
        else
          header[field_name] = args.first
        end
      else
        super # otherwise pass it on
      end
      #:startdoc:
    end

    # Returns an FieldList of all the fields in the header in the order that
    # they appear in the header
    def header_fields
      header.fields
    end

    # Returns true if the message has a message ID field, the field may or may
    # not have a value, but the field exists or not.
    def has_message_id?
      header.has_message_id?
    end

    # Returns true if the message has a Date field, the field may or may
    # not have a value, but the field exists or not.
    def has_date?
      header.has_date?
    end

    # Returns true if the message has a Mime-Version field, the field may or may
    # not have a value, but the field exists or not.
    def has_mime_version?
      header.has_mime_version?
    end

    def has_content_type?
      tmp = header[:content_type].main_type rescue nil
      !!tmp
    end

    def has_charset?
      tmp = header[:content_type].parameters rescue nil
      !!(has_content_type? && tmp && tmp['charset'])
    end

    def has_content_transfer_encoding?
      header[:content_transfer_encoding] && Utilities.blank?(header[:content_transfer_encoding].errors)
    end

    def has_transfer_encoding? # :nodoc:
      warn(":has_transfer_encoding? is deprecated in Mail 1.4.3.  Please use has_content_transfer_encoding?\n#{caller}")
      has_content_transfer_encoding?
    end

    # Creates a new empty Message-ID field and inserts it in the correct order
    # into the Header.  The MessageIdField object will automatically generate
    # a unique message ID if you try and encode it or output it to_s without
    # specifying a message id.
    #
    # It will preserve the message ID you specify if you do.
    def add_message_id(msg_id_val = '')
      header['message-id'] = msg_id_val
    end

    # Creates a new empty Date field and inserts it in the correct order
    # into the Header.  The DateField object will automatically generate
    # DateTime.now's date if you try and encode it or output it to_s without
    # specifying a date yourself.
    #
    # It will preserve any date you specify if you do.
    def add_date(date_val = '')
      header['date'] = date_val
    end

    # Creates a new empty Mime Version field and inserts it in the correct order
    # into the Header.  The MimeVersion object will automatically generate
    # set itself to '1.0' if you try and encode it or output it to_s without
    # specifying a version yourself.
    #
    # It will preserve any date you specify if you do.
    def add_mime_version(ver_val = '')
      header['mime-version'] = ver_val
    end

    # Adds a content type and charset if the body is US-ASCII
    #
    # Otherwise raises a warning
    def add_content_type
      header[:content_type] = 'text/plain'
    end

    # Adds a content type and charset if the body is US-ASCII
    #
    # Otherwise raises a warning
    def add_charset
      if !body.empty?
        # Only give a warning if this isn't an attachment, has non US-ASCII and the user
        # has not specified an encoding explicitly.
        if @defaulted_charset && !body.raw_source.ascii_only? && !self.attachment?
          warning = "Non US-ASCII detected and no charset defined.\nDefaulting to UTF-8, set your own if this is incorrect.\n"
          warn(warning)
        end
        header[:content_type].parameters['charset'] = @charset
      end
    end

    # Adds a content transfer encoding
    def add_content_transfer_encoding
      header[:content_transfer_encoding] ||= body.default_encoding
    end

    def add_transfer_encoding # :nodoc:
      warn(":add_transfer_encoding is deprecated in Mail 1.4.3.  Please use add_content_transfer_encoding\n#{caller}")
      add_content_transfer_encoding
    end

    def transfer_encoding # :nodoc:
      warn(":transfer_encoding is deprecated in Mail 1.4.3.  Please use content_transfer_encoding\n#{caller}")
      content_transfer_encoding
    end

    # Returns the MIME media type of part we are on, this is taken from the content-type header
    def mime_type
      has_content_type? ? header[:content_type].string : nil rescue nil
    end

    def message_content_type
      warn(":message_content_type is deprecated in Mail 1.4.3.  Please use mime_type\n#{caller}")
      mime_type
    end

    # Returns the character set defined in the content type field
    def charset
      if @header
        has_content_type? ? content_type_parameters['charset'] : @charset
      else
        @charset
      end
    end

    # Sets the charset to the supplied value.
    def charset=(value)
      @defaulted_charset = false
      @charset = value
      @header.charset = value
    end

    # Returns the main content type
    def main_type
      has_content_type? ? header[:content_type].main_type : nil rescue nil
    end

    # Returns the sub content type
    def sub_type
      has_content_type? ? header[:content_type].sub_type : nil rescue nil
    end

    # Returns the content type parameters
    def mime_parameters
      warn(':mime_parameters is deprecated in Mail 1.4.3, please use :content_type_parameters instead')
      content_type_parameters
    end

    # Returns the content type parameters
    def content_type_parameters
      has_content_type? ? header[:content_type].parameters : nil rescue nil
    end

    # Returns true if the message is multipart
    def multipart?
      has_content_type? ? !!(main_type =~ /^multipart$/i) : false
    end

    # Returns true if the message is a multipart/report
    def multipart_report?
      multipart? && sub_type =~ /^report$/i
    end

    # Returns true if the message is a multipart/report; report-type=delivery-status;
    def delivery_status_report?
      multipart_report? && content_type_parameters['report-type'] =~ /^delivery-status$/i
    end

    # returns the part in a multipart/report email that has the content-type delivery-status
    def delivery_status_part
      unless defined? @delivery_status_part
        @delivery_status_part =
          if delivery_status_report?
            parts.detect(&:delivery_status_report_part?)
          end
      end

      @delivery_status_part
    end

    def bounced?
      delivery_status_part and delivery_status_part.bounced?
    end

    def action
      delivery_status_part and delivery_status_part.action
    end

    def final_recipient
      delivery_status_part and delivery_status_part.final_recipient
    end

    def error_status
      delivery_status_part and delivery_status_part.error_status
    end

    def diagnostic_code
      delivery_status_part and delivery_status_part.diagnostic_code
    end

    def remote_mta
      delivery_status_part and delivery_status_part.remote_mta
    end

    def retryable?
      delivery_status_part and delivery_status_part.retryable?
    end

    # Returns the current boundary for this message part
    def boundary
      content_type_parameters ? content_type_parameters['boundary'] : nil
    end

    # Returns a parts list object of all the parts in the message
    def parts
      body.parts
    end

    # Returns an AttachmentsList object, which holds all of the attachments in
    # the receiver object (either the entire email or a part within) and all
    # of its descendants.
    #
    # It also allows you to add attachments to the mail object directly, like so:
    #
    #  mail.attachments['filename.jpg'] = File.read('/path/to/filename.jpg')
    #
    # If you do this, then Mail will take the file name and work out the MIME media type
    # set the Content-Type, Content-Disposition, Content-Transfer-Encoding and
    # base64 encode the contents of the attachment all for you.
    #
    # You can also specify overrides if you want by passing a hash instead of a string:
    #
    #  mail.attachments['filename.jpg'] = {:mime_type => 'application/x-gzip',
    #                                      :content => File.read('/path/to/filename.jpg')}
    #
    # If you want to use a different encoding than Base64, you can pass an encoding in,
    # but then it is up to you to pass in the content pre-encoded, and don't expect
    # Mail to know how to decode this data:
    #
    #  file_content = SpecialEncode(File.read('/path/to/filename.jpg'))
    #  mail.attachments['filename.jpg'] = {:mime_type => 'application/x-gzip',
    #                                      :encoding => 'SpecialEncoding',
    #                                      :content => file_content }
    #
    # You can also search for specific attachments:
    #
    #  # By Filename
    #  mail.attachments['filename.jpg']   #=> Mail::Part object or nil
    #
    #  # or by index
    #  mail.attachments[0]                #=> Mail::Part (first attachment)
    #
    def attachments
      parts.attachments
    end

    def has_attachments?
      !attachments.empty?
    end

    # Accessor for html_part
    def html_part(&block)
      if block_given?
        self.html_part = Mail::Part.new(:content_type => 'text/html', &block)
      else
        @html_part || find_first_mime_type('text/html')
      end
    end

    # Accessor for text_part
    def text_part(&block)
      if block_given?
        self.text_part = Mail::Part.new(:content_type => 'text/plain', &block)
      else
        @text_part || find_first_mime_type('text/plain')
      end
    end

    # Helper to add a html part to a multipart/alternative email.  If this and
    # text_part are both defined in a message, then it will be a multipart/alternative
    # message and set itself that way.
    def html_part=(msg)
      # Assign the html part and set multipart/alternative if there's a text part.
      if msg
        msg = Mail::Part.new(:body => msg) unless msg.kind_of?(Mail::Message)

        @html_part = msg
        @html_part.content_type = 'text/html' unless @html_part.has_content_type?
        add_multipart_alternate_header if text_part
        add_part @html_part

      # If nil, delete the html part and back out of multipart/alternative.
      elsif @html_part
        parts.delete_if { |p| p.object_id == @html_part.object_id }
        @html_part = nil
        if text_part
          self.content_type = nil
          body.boundary = nil
        end
      end
    end

    # Helper to add a text part to a multipart/alternative email.  If this and
    # html_part are both defined in a message, then it will be a multipart/alternative
    # message and set itself that way.
    def text_part=(msg)
      # Assign the text part and set multipart/alternative if there's an html part.
      if msg
        msg = Mail::Part.new(:body => msg) unless msg.kind_of?(Mail::Message)

        @text_part = msg
        @text_part.content_type = 'text/plain' unless @text_part.has_content_type?
        add_multipart_alternate_header if html_part
        add_part @text_part

      # If nil, delete the text part and back out of multipart/alternative.
      elsif @text_part
        parts.delete_if { |p| p.object_id == @text_part.object_id }
        @text_part = nil
        if html_part
          self.content_type = nil
          body.boundary = nil
        end
      end
    end

    # Adds a part to the parts list or creates the part list
    def add_part(part)
      if !body.multipart? && !Utilities.blank?(self.body.decoded)
        @text_part = Mail::Part.new('Content-Type: text/plain;')
        @text_part.body = body.decoded
        self.body << @text_part
        add_multipart_alternate_header
      end
      add_boundary
      self.body << part
    end

    # Allows you to add a part in block form to an existing mail message object
    #
    # Example:
    #
    #  mail = Mail.new do
    #    part :content_type => "multipart/alternative", :content_disposition => "inline" do |p|
    #      p.part :content_type => "text/plain", :body => "test text\nline #2"
    #      p.part :content_type => "text/html", :body => "<b>test</b> HTML<br/>\nline #2"
    #    end
    #  end
    def part(params = {})
      new_part = Part.new(params)
      yield new_part if block_given?
      add_part(new_part)
    end

    # Adds a file to the message.  You have two options with this method, you can
    # just pass in the absolute path to the file you want and Mail will read the file,
    # get the filename from the path you pass in and guess the MIME media type, or you
    # can pass in the filename as a string, and pass in the file content as a blob.
    #
    # Example:
    #
    #  m = Mail.new
    #  m.add_file('/path/to/filename.png')
    #
    #  m = Mail.new
    #  m.add_file(:filename => 'filename.png', :content => File.read('/path/to/file.jpg'))
    #
    # Note also that if you add a file to an existing message, Mail will convert that message
    # to a MIME multipart email, moving whatever plain text body you had into its own text
    # plain part.
    #
    # Example:
    #
    #  m = Mail.new do
    #    body 'this is some text'
    #  end
    #  m.multipart? #=> false
    #  m.add_file('/path/to/filename.png')
    #  m.multipart? #=> true
    #  m.parts.first.content_type.content_type #=> 'text/plain'
    #  m.parts.last.content_type.content_type #=> 'image/png'
    #
    # See also #attachments
    def add_file(values)
      convert_to_multipart unless self.multipart? || Utilities.blank?(self.body.decoded)
      add_multipart_mixed_header
      if values.is_a?(String)
        basename = File.basename(values)
        filedata = File.open(values, 'rb') { |f| f.read }
      else
        basename = values[:filename]
        filedata = values
      end
      self.attachments[basename] = filedata
    end

    def convert_to_multipart
      text = body.decoded
      self.body = ''
      text_part = Mail::Part.new({:content_type => 'text/plain;',
                                  :body => text})
      text_part.charset = charset unless @defaulted_charset
      self.body << text_part
    end

    # Encodes the message, calls encode on all its parts, gets an email message
    # ready to send
    def ready_to_send!
      identify_and_set_transfer_encoding
      parts.each do |part|
        part.transport_encoding = transport_encoding
        part.ready_to_send!
      end
      add_required_fields
    end

    def encode!
      warn("Deprecated in 1.1.0 in favour of :ready_to_send! as it is less confusing with encoding and decoding.")
      ready_to_send!
    end

    # Outputs an encoded string representation of the mail message including
    # all headers, attachments, etc.  This is an encoded email in US-ASCII,
    # so it is able to be directly sent to an email server.
    def encoded
      ready_to_send!
      buffer = header.encoded
      buffer << "\r\n"
      buffer << body.encoded(content_transfer_encoding)
      buffer
    end

    def without_attachments!
      if has_attachments?
        parts.delete_if { |p| p.attachment? }

        reencoded = parts.empty? ? '' : body.encoded(content_transfer_encoding)
        @body = nil # So the new parts won't be added to the existing body
        self.body = reencoded
      end

      self
    end

    def to_yaml(opts = {})
      hash = {}
      hash['headers'] = {}
      header.fields.each do |field|
        hash['headers'][field.name] = field.value
      end
      hash['delivery_handler'] = delivery_handler.to_s if delivery_handler
      hash['transport_encoding'] = transport_encoding.to_s
      special_variables = [:@header, :@delivery_handler, :@transport_encoding]
      if multipart?
        hash['multipart_body'] = []
        body.parts.map { |part| hash['multipart_body'] << part.to_yaml }
        special_variables.push(:@body, :@text_part, :@html_part)
      end
      (instance_variables.map(&:to_sym) - special_variables).each do |var|
        hash[var.to_s] = instance_variable_get(var)
      end
      hash.to_yaml(opts)
    end

    def self.from_yaml(str)
      hash = YAML.load(str)
      m = self.new(:headers => hash['headers'])
      hash.delete('headers')
      hash.each do |k,v|
        case
        when k == 'delivery_handler'
          begin
            m.delivery_handler = Object.const_get(v) unless Utilities.blank?(v)
          rescue NameError
          end
        when k == 'transport_encoding'
          m.transport_encoding(v)
        when k == 'multipart_body'
          v.map {|part| m.add_part Mail::Part.from_yaml(part) }
        when k =~ /^@/
          m.instance_variable_set(k.to_sym, v)
        end
      end
      m
    end

    def self.from_hash(hash)
      Mail::Message.new(hash)
    end

    def to_s
      encoded
    end

    def inspect
      "#<#{self.class}:#{self.object_id}, Multipart: #{multipart?}, Headers: #{header.field_summary}>"
    end

    def decoded
      case
      when self.text?
        decode_body_as_text
      when self.attachment?
        decode_body
      when !self.multipart?
        body.decoded
      else
        raise NoMethodError, 'Can not decode an entire message, try calling #decoded on the various fields and body or parts if it is a multipart message.'
      end
    end

    def read
      if self.attachment?
        decode_body
      else
        raise NoMethodError, 'Can not call read on a part unless it is an attachment.'
      end
    end

    def decode_body
      body.decoded
    end

    # Returns true if this part is an attachment,
    # false otherwise.
    def attachment?
      !!find_attachment
    end

    # Returns the attachment data if there is any
    def attachment
      @attachment
    end

    # Returns the filename of the attachment
    def filename
      find_attachment
    end

    def all_parts
      parts.map { |p| [p, p.all_parts] }.flatten
    end

    def find_first_mime_type(mt)
      all_parts.detect { |p| p.mime_type == mt && !p.attachment? }
    end

    # Skips the deletion of this message. All other messages
    # flagged for delete still will be deleted at session close (i.e. when
    # #find exits). Only has an effect if you're using #find_and_delete
    # or #find with :delete_after_find set to true.
    def skip_deletion
      @mark_for_delete = false
    end

    # Sets whether this message should be deleted at session close (i.e.
    # after #find). Message will only be deleted if messages are retrieved
    # using the #find_and_delete method, or by calling #find with
    # :delete_after_find set to true.
    def mark_for_delete=(value = true)
      @mark_for_delete = value
    end

    # Returns whether message will be marked for deletion.
    # If so, the message will be deleted at session close (i.e. after #find
    # exits), but only if also using the #find_and_delete method, or by
    # calling #find with :delete_after_find set to true.
    #
    # Side-note: Just to be clear, this method will return true even if
    # the message hasn't yet been marked for delete on the mail server.
    # However, if this method returns true, it *will be* marked on the
    # server after each block yields back to #find or #find_and_delete.
    def is_marked_for_delete?
      return @mark_for_delete
    end

    def text?
      has_content_type? ? !!(main_type =~ /^text$/i) : false
    end

  private

    HEADER_SEPARATOR = /#{CRLF}#{CRLF}/

    #  2.1. General Description
    #   A message consists of header fields (collectively called "the header
    #   of the message") followed, optionally, by a body.  The header is a
    #   sequence of lines of characters with special syntax as defined in
    #   this standard. The body is simply a sequence of characters that
    #   follows the header and is separated from the header by an empty line
    #   (i.e., a line with nothing preceding the CRLF).
    def parse_message
      header_part, body_part = raw_source.lstrip.split(HEADER_SEPARATOR, 2)
      self.header = header_part
      self.body   = body_part
    end

    def raw_source=(value)
      value = value.dup.force_encoding(Encoding::BINARY) if RUBY_VERSION >= "1.9.1"
      @raw_source = ::Mail::Utilities.to_crlf(value)
    end

    # see comments to body=. We take data and process it lazily
    def body_lazy(value)
      process_body_raw if @body_raw && value
      case
      when value == nil || value.length<=0
        @body = Mail::Body.new('')
        @body_raw = nil
        add_encoding_to_body
      when @body && @body.multipart?
        self.text_part = value
      else
        @body_raw = value
      end
    end


    def process_body_raw
      @body = Mail::Body.new(@body_raw)
      @body_raw = nil
      separate_parts if @separate_parts

      add_encoding_to_body
    end

    def set_envelope_header
      raw_string = raw_source.to_s
      if match_data = raw_string.match(/\AFrom\s(#{TEXT}+)#{CRLF}/m)
        set_envelope(match_data[1])
        self.raw_source = raw_string.sub(match_data[0], "")
      end
    end

    def separate_parts
      body.split!(boundary)
    end

    def allowed_encodings
      case mime_type
      when 'message/rfc822'
        [Encodings::SevenBit, Encodings::EightBit, Encodings::Binary]
      end
    end

    def add_encoding_to_body
      if has_content_transfer_encoding?
        @body.encoding = content_transfer_encoding
      end
    end

    def identify_and_set_transfer_encoding
      if body && body.multipart?
        self.content_transfer_encoding = @transport_encoding
      else
        self.content_transfer_encoding = body.negotiate_best_encoding(@transport_encoding, allowed_encodings).to_s
      end
    end

    def add_required_fields
      add_required_message_fields
      add_multipart_mixed_header    if body.multipart?
      add_content_type              unless has_content_type?
      add_charset                   if text? && !has_charset?
      add_content_transfer_encoding unless has_content_transfer_encoding?
    end

    def add_required_message_fields
      add_date          unless has_date?
      add_mime_version  unless has_mime_version?
      add_message_id    unless has_message_id?
    end

    def add_multipart_alternate_header
      header['content-type'] = ContentTypeField.with_boundary('multipart/alternative').value
      header['content_type'].parameters[:charset] = @charset
      body.boundary = boundary
    end

    def add_boundary
      unless body.boundary && boundary
        header['content-type'] = 'multipart/mixed' unless header['content-type']
        header['content-type'].parameters[:boundary] = ContentTypeField.generate_boundary
        header['content_type'].parameters[:charset] = @charset
        body.boundary = boundary
      end
    end

    def add_multipart_mixed_header
      unless header['content-type']
        header['content-type'] = ContentTypeField.with_boundary('multipart/mixed').value
        header['content_type'].parameters[:charset] = @charset
        body.boundary = boundary
      end
    end

    def init_with_hash(hash)
      passed_in_options = IndifferentHash.new(hash)
      self.raw_source = ''

      @header = Mail::Header.new
      @body = Mail::Body.new
      @body_raw = nil

      # We need to store the body until last, as we need all headers added first
      body_content = nil

      passed_in_options.each_pair do |k,v|
        k = underscoreize(k).to_sym if k.class == String
        if k == :headers
          self.headers(v)
        elsif k == :body
          body_content = v
        else
          self[k] = v
        end
      end

      if body_content
        self.body = body_content
        if has_content_transfer_encoding?
            body.encoding = content_transfer_encoding
        end
      end
    end

    def init_with_string(string)
      self.raw_source = string
      set_envelope_header
      parse_message
      @separate_parts = multipart?
    end

    # Returns the filename of the attachment (if it exists) or returns nil
    def find_attachment
      content_type_name = header[:content_type].filename rescue nil
      content_disp_name = header[:content_disposition].filename rescue nil
      content_loc_name  = header[:content_location].location rescue nil
      case
      when content_disposition && content_disp_name
        filename = content_disp_name
      when content_type && content_type_name
        filename = content_type_name
      when content_location && content_loc_name
        filename = content_loc_name
      else
        filename = nil
      end
      filename = Mail::Encodings.decode_encode(filename, :decode) if filename rescue filename
      filename
    end

    def do_delivery
      begin
        if perform_deliveries
          delivery_method.deliver!(self)
        end
      rescue => e # Net::SMTP errors or sendmail pipe errors
        raise e if raise_delivery_errors
      end
    end

    def decode_body_as_text
      Encodings.transcode_charset decode_body, charset, 'UTF-8'
    end
  end
end
