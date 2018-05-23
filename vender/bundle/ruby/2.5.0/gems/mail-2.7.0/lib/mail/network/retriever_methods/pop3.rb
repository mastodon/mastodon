# encoding: utf-8
# frozen_string_literal: true

module Mail
  # The Pop3 retriever allows to get the last, first or all emails from a POP3 server.
  # Each email retrieved (RFC2822) is given as an instance of +Message+.
  #
  # While being retrieved, emails can be yielded if a block is given.
  # 
  # === Example of retrieving Emails from GMail:
  # 
  #   Mail.defaults do
  #     retriever_method :pop3, { :address             => "pop.gmail.com",
  #                               :port                => 995,
  #                               :user_name           => '<username>',
  #                               :password            => '<password>',
  #                               :enable_ssl          => true }
  #   end
  # 
  #   Mail.all    #=> Returns an array of all emails
  #   Mail.first  #=> Returns the first unread email
  #   Mail.last   #=> Returns the last unread email
  # 
  # You can also pass options into Mail.find to locate an email in your pop mailbox
  # with the following options:
  # 
  #   what:  last or first emails. The default is :first.
  #   order: order of emails returned. Possible values are :asc or :desc. Default value is :asc.
  #   count: number of emails to retrieve. The default value is 10. A value of 1 returns an
  #          instance of Message, not an array of Message instances.
  # 
  #   Mail.find(:what => :first, :count => 10, :order => :asc)
  #   #=> Returns the first 10 emails in ascending order
  # 
  class POP3 < Retriever
    require 'net/pop' unless defined?(Net::POP)

    def initialize(values)
      self.settings = { :address              => "localhost",
                        :port                 => 110,
                        :user_name            => nil,
                        :password             => nil,
                        :authentication       => nil,
                        :enable_ssl           => false,
                        :read_timeout         => nil }.merge!(values)
    end
    
    attr_accessor :settings
    
    # Find emails in a POP3 mailbox. Without any options, the 5 last received emails are returned.
    #
    # Possible options:
    #   what:  last or first emails. The default is :first.
    #   order: order of emails returned. Possible values are :asc or :desc. Default value is :asc.
    #   count: number of emails to retrieve. The default value is 10. A value of 1 returns an
    #          instance of Message, not an array of Message instances.
    #   delete_after_find: flag for whether to delete each retreived email after find. Default
    #           is false. Use #find_and_delete if you would like this to default to true.
    #
    def find(options = {}, &block)
      options = validate_options(options)
      
      start do |pop3|
        mails = pop3.mails
        pop3.reset # Clears all "deleted" marks. This prevents non-explicit/accidental deletions due to server settings.
        mails.sort! { |m1, m2| m2.number <=> m1.number } if options[:what] == :last
        mails = mails.first(options[:count]) if options[:count].is_a? Integer
        
        if options[:what].to_sym == :last && options[:order].to_sym == :desc ||
           options[:what].to_sym == :first && options[:order].to_sym == :asc ||
          mails.reverse!
        end
        
        if block_given?
          mails.each do |mail|
            new_message = Mail.new(mail.pop)
            new_message.mark_for_delete = true if options[:delete_after_find]
            yield new_message
            mail.delete if options[:delete_after_find] && new_message.is_marked_for_delete? # Delete if still marked for delete
          end
        else
          emails = []
          mails.each do |mail|
            emails << Mail.new(mail.pop)
            mail.delete if options[:delete_after_find]
          end
          emails.size == 1 && options[:count] == 1 ? emails.first : emails
        end
        
      end
    end
    
    # Delete all emails from a POP3 server   
    def delete_all
      start do |pop3|
        unless pop3.mails.empty?
          pop3.delete_all
          pop3.finish
        end
      end
    end

    # Returns the connection object of the retrievable (IMAP or POP3)
    def connection(&block)
      raise ArgumentError.new('Mail::Retrievable#connection takes a block') unless block_given?

      start do |pop3|
        yield pop3
      end
    end
    
  private
  
    # Set default options
    def validate_options(options)
      options ||= {}
      options[:count] ||= 10
      options[:order] ||= :asc
      options[:what]  ||= :first
      options[:delete_after_find] ||= false
      options
    end
  
    # Start a POP3 session and ensure that it will be closed in any case. Any messages
    # marked for deletion via #find_and_delete or with the :delete_after_find option
    # will be deleted when the session is closed.
    def start(config = Configuration.instance, &block)
      raise ArgumentError.new("Mail::Retrievable#pop3_start takes a block") unless block_given?
    
      pop3 = Net::POP3.new(settings[:address], settings[:port], false)
      pop3.enable_ssl(OpenSSL::SSL::VERIFY_NONE) if settings[:enable_ssl]
      pop3.read_timeout = settings[:read_timeout] if settings[:read_timeout]
      pop3.start(settings[:user_name], settings[:password])
    
      yield pop3
    ensure
      if defined?(pop3) && pop3 && pop3.started?
        pop3.finish
      end
    end

  end
end
