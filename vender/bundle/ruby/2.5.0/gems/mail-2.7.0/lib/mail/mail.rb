# encoding: utf-8
# frozen_string_literal: true
module Mail

  # Allows you to create a new Mail::Message object.
  # 
  # You can make an email via passing a string or passing a block.
  # 
  # For example, the following two examples will create the same email
  # message:
  # 
  # Creating via a string:
  # 
  #  string = "To: mikel@test.lindsaar.net\r\n"
  #  string << "From: bob@test.lindsaar.net\r\n"
  #  string << "Subject: This is an email\r\n"
  #  string << "\r\n"
  #  string << "This is the body"
  #  Mail.new(string)
  # 
  # Or creating via a block:
  # 
  #  message = Mail.new do
  #    to 'mikel@test.lindsaar.net'
  #    from 'bob@test.lindsaar.net'
  #    subject 'This is an email'
  #    body 'This is the body'
  #  end
  # 
  # Or creating via a hash (or hash like object):
  # 
  #  message = Mail.new({:to => 'mikel@test.lindsaar.net',
  #                      'from' => 'bob@test.lindsaar.net',
  #                      :subject => 'This is an email',
  #                      :body => 'This is the body' })
  # 
  # Note, the hash keys can be strings or symbols, the passed in object
  # does not need to be a hash, it just needs to respond to :each_pair
  # and yield each key value pair.
  # 
  # As a side note, you can also create a new email through creating
  # a Mail::Message object directly and then passing in values via string,
  # symbol or direct method calls.  See Mail::Message for more information.
  # 
  #  mail = Mail.new
  #  mail.to = 'mikel@test.lindsaar.net'
  #  mail[:from] = 'bob@test.lindsaar.net'
  #  mail['subject'] = 'This is an email'
  #  mail.body = 'This is the body'
  def self.new(*args, &block)
    Message.new(args, &block)
  end

  # Sets the default delivery method and retriever method for all new Mail objects.
  # The delivery_method and retriever_method default to :smtp and :pop3, with defaults
  # set.
  # 
  # So sending a new email, if you have an SMTP server running on localhost is
  # as easy as:
  # 
  #   Mail.deliver do
  #     to      'mikel@test.lindsaar.net'
  #     from    'bob@test.lindsaar.net'
  #     subject 'hi there!'
  #     body    'this is a body'
  #   end
  # 
  # If you do not specify anything, you will get the following equivalent code set in
  # every new mail object:
  # 
  #   Mail.defaults do
  #     delivery_method :smtp, { :address              => "localhost",
  #                              :port                 => 25,
  #                              :domain               => 'localhost.localdomain',
  #                              :user_name            => nil,
  #                              :password             => nil,
  #                              :authentication       => nil,
  #                              :enable_starttls_auto => true  }
  # 
  #     retriever_method :pop3, { :address             => "localhost",
  #                               :port                => 995,
  #                               :user_name           => nil,
  #                               :password            => nil,
  #                               :enable_ssl          => true }
  #   end
  # 
  #   Mail.delivery_method.new  #=> Mail::SMTP instance
  #   Mail.retriever_method.new #=> Mail::POP3 instance
  #
  # Each mail object inherits the default set in Mail.delivery_method, however, on
  # a per email basis, you can override the method:
  #
  #   mail.delivery_method :smtp
  # 
  # Or you can override the method and pass in settings:
  # 
  #   mail.delivery_method :smtp, :address => 'some.host'
  def self.defaults(&block)
    Configuration.instance.instance_eval(&block)
  end

  # Returns the delivery method selected, defaults to an instance of Mail::SMTP
  def self.delivery_method
    Configuration.instance.delivery_method
  end

  # Returns the retriever method selected, defaults to an instance of Mail::POP3
  def self.retriever_method
    Configuration.instance.retriever_method
  end

  # Send an email using the default configuration.  You do need to set a default
  # configuration first before you use self.deliver, if you don't, an appropriate
  # error will be raised telling you to.
  # 
  # If you do not specify a delivery type, SMTP will be used.
  # 
  #  Mail.deliver do
  #   to 'mikel@test.lindsaar.net'
  #   from 'ada@test.lindsaar.net'
  #   subject 'This is a test email'
  #   body 'Not much to say here'
  #  end
  # 
  # You can also do:
  # 
  #  mail = Mail.read('email.eml')
  #  mail.deliver!
  # 
  # And your email object will be created and sent.
  def self.deliver(*args, &block)
    mail = self.new(args, &block)
    mail.deliver
    mail
  end

  # Find emails from the default retriever
  # See Mail::Retriever for a complete documentation.
  def self.find(*args, &block)
    retriever_method.find(*args, &block)
  end

  # Finds and then deletes retrieved emails from the default retriever
  # See Mail::Retriever for a complete documentation.
  def self.find_and_delete(*args, &block)
    retriever_method.find_and_delete(*args, &block)
  end

  # Receive the first email(s) from the default retriever
  # See Mail::Retriever for a complete documentation.
  def self.first(*args, &block)
    retriever_method.first(*args, &block)
  end

  # Receive the first email(s) from the default retriever
  # See Mail::Retriever for a complete documentation.
  def self.last(*args, &block)
    retriever_method.last(*args, &block)
  end

  # Receive all emails from the default retriever
  # See Mail::Retriever for a complete documentation.
  def self.all(*args, &block)
    retriever_method.all(*args, &block)
  end

  # Reads in an email message from a path and instantiates it as a new Mail::Message
  def self.read(filename)
    self.new(File.open(filename, 'rb') { |f| f.read })
  end

  # Delete all emails from the default retriever
  # See Mail::Retriever for a complete documentation.
  def self.delete_all(*args, &block)
    retriever_method.delete_all(*args, &block)
  end

  # Instantiates a new Mail::Message using a string
  def Mail.read_from_string(mail_as_string)
    Mail.new(mail_as_string)
  end

  def Mail.connection(&block)
    retriever_method.connection(&block)
  end

  # Initialize the observers and interceptors arrays
  @@delivery_notification_observers = []
  @@delivery_interceptors = []

  # You can register an object to be informed of every email that is sent through
  # this method.
  # 
  # Your object needs to respond to a single method #delivered_email(mail)
  # which receives the email that is sent.
  def self.register_observer(observer)
    unless @@delivery_notification_observers.include?(observer)
      @@delivery_notification_observers << observer
    end
  end

  # Unregister the given observer, allowing mail to resume operations
  # without it.
  def self.unregister_observer(observer)
    @@delivery_notification_observers.delete(observer)
  end

  # You can register an object to be given every mail object that will be sent,
  # before it is sent.  So if you want to add special headers or modify any
  # email that gets sent through the Mail library, you can do so.
  # 
  # Your object needs to respond to a single method #delivering_email(mail)
  # which receives the email that is about to be sent.  Make your modifications
  # directly to this object.
  def self.register_interceptor(interceptor)
    unless @@delivery_interceptors.include?(interceptor)
      @@delivery_interceptors << interceptor
    end
  end

  # Unregister the given interceptor, allowing mail to resume operations
  # without it.
  def self.unregister_interceptor(interceptor)
    @@delivery_interceptors.delete(interceptor)
  end

  def self.inform_observers(mail)
    @@delivery_notification_observers.each do |observer|
      observer.delivered_email(mail)
    end
  end

  def self.inform_interceptors(mail)
    @@delivery_interceptors.each do |interceptor|
      interceptor.delivering_email(mail)
    end
  end

  protected

  RANDOM_TAG='%x%x_%x%x%d%x'

  def self.random_tag
    t = Time.now
    sprintf(RANDOM_TAG,
            t.to_i, t.tv_usec,
            $$, Thread.current.object_id.abs, self.uniq, rand(255))
  end

  private

  def self.something_random
    (Thread.current.object_id * rand(255) / Time.now.to_f).to_s.slice(-3..-1).to_i
  end

  def self.uniq
    @@uniq += 1
  end

  @@uniq = self.something_random

end
