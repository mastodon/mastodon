# frozen_string_literal: true
module Mail
  register_autoload :Address, 'mail/elements/address'
  register_autoload :AddressList, 'mail/elements/address_list'
  register_autoload :ContentDispositionElement, 'mail/elements/content_disposition_element'
  register_autoload :ContentLocationElement, 'mail/elements/content_location_element'
  register_autoload :ContentTransferEncodingElement, 'mail/elements/content_transfer_encoding_element'
  register_autoload :ContentTypeElement, 'mail/elements/content_type_element'
  register_autoload :DateTimeElement, 'mail/elements/date_time_element'
  register_autoload :EnvelopeFromElement, 'mail/elements/envelope_from_element'
  register_autoload :MessageIdsElement, 'mail/elements/message_ids_element'
  register_autoload :MimeVersionElement, 'mail/elements/mime_version_element'
  register_autoload :PhraseList, 'mail/elements/phrase_list'
  register_autoload :ReceivedElement, 'mail/elements/received_element'
end
