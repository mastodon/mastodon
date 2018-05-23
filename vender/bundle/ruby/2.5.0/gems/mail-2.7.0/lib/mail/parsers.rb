# frozen_string_literal: true
# Ragel-generated parsers are full of known warnings. Suppress them.
begin
  orig, $VERBOSE = $VERBOSE, nil

  require 'mail/parsers/address_lists_parser'
  require 'mail/parsers/content_disposition_parser'
  require 'mail/parsers/content_location_parser'
  require 'mail/parsers/content_transfer_encoding_parser'
  require 'mail/parsers/content_type_parser'
  require 'mail/parsers/date_time_parser'
  require 'mail/parsers/envelope_from_parser'
  require 'mail/parsers/message_ids_parser'
  require 'mail/parsers/mime_version_parser'
  require 'mail/parsers/phrase_lists_parser'
  require 'mail/parsers/received_parser'
ensure
  $VERBOSE = orig
end
