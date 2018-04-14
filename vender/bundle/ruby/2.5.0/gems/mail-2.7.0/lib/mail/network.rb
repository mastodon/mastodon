# frozen_string_literal: true
require 'mail/network/retriever_methods/base'

module Mail
  register_autoload :SMTP, 'mail/network/delivery_methods/smtp'
  register_autoload :FileDelivery, 'mail/network/delivery_methods/file_delivery'
  register_autoload :LoggerDelivery, 'mail/network/delivery_methods/logger_delivery'
  register_autoload :Sendmail, 'mail/network/delivery_methods/sendmail'
  register_autoload :Exim, 'mail/network/delivery_methods/exim'
  register_autoload :SMTPConnection, 'mail/network/delivery_methods/smtp_connection'
  register_autoload :TestMailer, 'mail/network/delivery_methods/test_mailer'

  register_autoload :POP3, 'mail/network/retriever_methods/pop3'
  register_autoload :IMAP, 'mail/network/retriever_methods/imap'
  register_autoload :TestRetriever, 'mail/network/retriever_methods/test_retriever'
end
