# frozen_string_literal: true
require 'mail/check_delivery_params'

module Mail
  # FileDelivery class delivers emails into multiple files based on the destination
  # address.  Each file is appended to if it already exists.
  # 
  # So if you have an email going to fred@test, bob@test, joe@anothertest, and you
  # set your location path to /path/to/mails then FileDelivery will create the directory
  # if it does not exist, and put one copy of the email in three files, called
  # by their message id
  # 
  # Make sure the path you specify with :location is writable by the Ruby process
  # running Mail.
  class FileDelivery
    if RUBY_VERSION >= '1.9.1'
      require 'fileutils'
    else
      require 'ftools'
    end

    attr_accessor :settings

    def initialize(values)
      self.settings = { :location => './mails' }.merge!(values)
    end

    def deliver!(mail)
      Mail::CheckDeliveryParams.check(mail)

      if ::File.respond_to?(:makedirs)
        ::File.makedirs settings[:location]
      else
        ::FileUtils.mkdir_p settings[:location]
      end

      mail.destinations.uniq.each do |to|
        ::File.open(::File.join(settings[:location], File.basename(to.to_s)), 'a') { |f| "#{f.write(mail.encoded)}\r\n\r\n" }
      end
    end
  end
end
