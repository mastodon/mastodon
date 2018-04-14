# encoding: utf-8
# frozen_string_literal: true
module Mail # :doc:

  require 'date'
  require 'shellwords'

  require 'uri'
  require 'net/smtp'
  require 'mini_mime'

  if RUBY_VERSION <= '1.8.6'
    begin
      require 'tlsmail'
    rescue LoadError
      raise "You need to install tlsmail if you are using ruby <= 1.8.6"
    end
  end

  if RUBY_VERSION >= "1.9.0"
    require 'mail/version_specific/ruby_1_9'
    RubyVer = Ruby19
  else
    require 'mail/version_specific/ruby_1_8'
    RubyVer = Ruby18
  end

  require 'mail/version'

  require 'mail/core_extensions/string'
  require 'mail/core_extensions/smtp'
  require 'mail/indifferent_hash'

  require 'mail/multibyte'

  require 'mail/constants'
  require 'mail/utilities'
  require 'mail/configuration'

  @@autoloads = {}
  def self.register_autoload(name, path)
    @@autoloads[name] = path
    autoload(name, path)
  end

  # This runs through the autoload list and explictly requires them for you.
  # Useful when running mail in a threaded process.
  #
  # Usage:
  #
  #   require 'mail'
  #   Mail.eager_autoload!
  def self.eager_autoload!
    @@autoloads.each { |_,path| require(path) }
  end

  # Autoload mail send and receive classes.
  require 'mail/network'

  require 'mail/message'
  require 'mail/part'
  require 'mail/header'
  require 'mail/parts_list'
  require 'mail/attachments_list'
  require 'mail/body'
  require 'mail/field'
  require 'mail/field_list'

  require 'mail/envelope'

  register_autoload :Parsers, "mail/parsers"

  # Autoload header field elements and transfer encodings.
  require 'mail/elements'
  require 'mail/encodings'
  require 'mail/encodings/base64'
  require 'mail/encodings/quoted_printable'
  require 'mail/encodings/unix_to_unix'

  require 'mail/matchers/has_sent_mail'
  require 'mail/matchers/attachment_matchers.rb'

  # Finally... require all the Mail.methods
  require 'mail/mail'
end
