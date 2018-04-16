# encoding: utf-8
# frozen_string_literal: true

module Mail
  # The IMAP retriever allows to get the last, first or all emails from a IMAP server.
  # Each email retrieved (RFC2822) is given as an instance of +Message+.
  #
  # While being retrieved, emails can be yielded if a block is given.
  #
  # === Example of retrieving Emails from GMail:
  #
  #   Mail.defaults do
  #     retriever_method :imap, { :address             => "imap.googlemail.com",
  #                               :port                => 993,
  #                               :user_name           => '<username>',
  #                               :password            => '<password>',
  #                               :enable_ssl          => true }
  #   end
  #
  #   Mail.all    #=> Returns an array of all emails
  #   Mail.first  #=> Returns the first unread email
  #   Mail.last   #=> Returns the last unread email
  #
  # You can also pass options into Mail.find to locate an email in your imap mailbox
  # with the following options:
  #
  #   mailbox: name of the mailbox used for email retrieval. The default is 'INBOX'.
  #   what:    last or first emails. The default is :first.
  #   order:   order of emails returned. Possible values are :asc or :desc. Default value is :asc.
  #   count:   number of emails to retrieve. The default value is 10. A value of 1 returns an
  #            instance of Message, not an array of Message instances.
  #   keys:    are passed as criteria to the SEARCH command.  They can either be a string holding the entire search string, 
  #            or a single-dimension array of search keywords and arguments.  Refer to  [IMAP] section 6.4.4 for a full list
  #            The default is 'ALL'
  #
  #   Mail.find(:what => :first, :count => 10, :order => :asc, :keys=>'ALL')
  #   #=> Returns the first 10 emails in ascending order
  #
  class IMAP < Retriever
    require 'net/imap' unless defined?(Net::IMAP)
    
    def initialize(values)
      self.settings = { :address              => "localhost",
                        :port                 => 143,
                        :user_name            => nil,
                        :password             => nil,
                        :authentication       => nil,
                        :enable_ssl           => false,
                        :enable_starttls      => false }.merge!(values)
    end

    attr_accessor :settings

    # Find emails in a IMAP mailbox. Without any options, the 10 last received emails are returned.
    #
    # Possible options:
    #   mailbox: mailbox to search the email(s) in. The default is 'INBOX'.
    #   what:    last or first emails. The default is :first.
    #   order:   order of emails returned. Possible values are :asc or :desc. Default value is :asc.
    #   count:   number of emails to retrieve. The default value is 10. A value of 1 returns an
    #            instance of Message, not an array of Message instances.
    #   read_only: will ensure that no writes are made to the inbox during the session.  Specifically, if this is
    #              set to true, the code will use the EXAMINE command to retrieve the mail.  If set to false, which
    #              is the default, a SELECT command will be used to retrieve the mail
    #              This is helpful when you don't want your messages to be set to read automatically. Default is false.
    #   delete_after_find: flag for whether to delete each retreived email after find. Default
    #           is false. Use #find_and_delete if you would like this to default to true.
    #   keys:   are passed as criteria to the SEARCH command.  They can either be a string holding the entire search string, 
    #           or a single-dimension array of search keywords and arguments.  Refer to  [IMAP] section 6.4.4 for a full list
    #           The default is 'ALL'
    #   search_charset: charset to pass to IMAP server search. Omitted by default. Example: 'UTF-8' or 'ASCII'.
    #
    def find(options={}, &block)
      options = validate_options(options)

      start do |imap|
        options[:read_only] ? imap.examine(options[:mailbox]) : imap.select(options[:mailbox])
        uids = imap.uid_search(options[:keys], options[:search_charset])
        uids.reverse! if options[:what].to_sym == :last
        uids = uids.first(options[:count]) if options[:count].is_a?(Integer)
        uids.reverse! if (options[:what].to_sym == :last && options[:order].to_sym == :asc) ||
                                (options[:what].to_sym != :last && options[:order].to_sym == :desc)

        if block_given?
          uids.each do |uid|
            uid = options[:uid].to_i unless options[:uid].nil?
            fetchdata = imap.uid_fetch(uid, ['RFC822', 'FLAGS'])[0]
            new_message = Mail.new(fetchdata.attr['RFC822'])
            new_message.mark_for_delete = true if options[:delete_after_find]

            if block.arity == 4
              yield new_message, imap, uid, fetchdata.attr['FLAGS']
            elsif block.arity == 3
              yield new_message, imap, uid
            else
              yield new_message
            end

            imap.uid_store(uid, "+FLAGS", [Net::IMAP::DELETED]) if options[:delete_after_find] && new_message.is_marked_for_delete?
            break unless options[:uid].nil?
          end
          imap.expunge if options[:delete_after_find]
        else
          emails = []
          uids.each do |uid|
            uid = options[:uid].to_i unless options[:uid].nil?
            fetchdata = imap.uid_fetch(uid, ['RFC822'])[0]
            emails << Mail.new(fetchdata.attr['RFC822'])
            imap.uid_store(uid, "+FLAGS", [Net::IMAP::DELETED]) if options[:delete_after_find]
            break unless options[:uid].nil?
          end
          imap.expunge if options[:delete_after_find]
          emails.size == 1 && options[:count] == 1 ? emails.first : emails
        end
      end
    end

    # Delete all emails from a IMAP mailbox
    def delete_all(mailbox='INBOX')
      mailbox ||= 'INBOX'
      mailbox = Net::IMAP.encode_utf7(mailbox)

      start do |imap|
        imap.examine(mailbox)
        imap.uid_search(['ALL']).each do |uid|
          imap.uid_store(uid, "+FLAGS", [Net::IMAP::DELETED])
        end
        imap.expunge
      end
    end

    # Returns the connection object of the retrievable (IMAP or POP3)
    def connection(&block)
      raise ArgumentError.new('Mail::Retrievable#connection takes a block') unless block_given?

      start do |imap|
        yield imap
      end
    end

    private

      # Set default options
      def validate_options(options)
        options ||= {}
        options[:mailbox] ||= 'INBOX'
        options[:count]   ||= 10
        options[:order]   ||= :asc
        options[:what]    ||= :first
        options[:keys]    ||= 'ALL'
        options[:uid]     ||= nil
        options[:delete_after_find] ||= false
        options[:mailbox] = Net::IMAP.encode_utf7(options[:mailbox])
        options[:read_only] ||= false

        options
      end

      # Start an IMAP session and ensures that it will be closed in any case.
      def start(config=Mail::Configuration.instance, &block)
        raise ArgumentError.new("Mail::Retrievable#imap_start takes a block") unless block_given?

        if settings[:enable_starttls] && settings[:enable_ssl]
          raise ArgumentError, ":enable_starttls and :enable_ssl are mutually exclusive. Set :enable_ssl if you're on an IMAPS connection. Set :enable_starttls if you're on an IMAP connection and using STARTTLS for secure TLS upgrade."
        end

        imap = Net::IMAP.new(settings[:address], settings[:port], settings[:enable_ssl], nil, false)

        imap.starttls if settings[:enable_starttls]

        if settings[:authentication].nil?
          imap.login(settings[:user_name], settings[:password])
        else
          # Note that Net::IMAP#authenticate('LOGIN', ...) is not equal with Net::IMAP#login(...)!
          # (see also http://www.ensta.fr/~diam/ruby/online/ruby-doc-stdlib/libdoc/net/imap/rdoc/classes/Net/IMAP.html#M000718)
          imap.authenticate(settings[:authentication], settings[:user_name], settings[:password])
        end

        yield imap
      ensure
        if defined?(imap) && imap && !imap.disconnected?
          imap.disconnect
        end
      end

  end
end
