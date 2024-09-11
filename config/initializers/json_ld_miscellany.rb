# frozen_string_literal: true
# This file generated automatically from https://purl.archive.org/socialweb/miscellany
require 'json/ld'
class JSON::LD::Context
  add_preloaded("http://purl.archive.org/socialweb/miscellany") do
    new(processingMode: "json-ld-1.1", term_definitions: {
      "Hashtag" => TermDefinition.new("Hashtag", id: "https://www.w3.org/ns/activitystreams#Hashtag", simple: true),
      "as" => TermDefinition.new("as", id: "https://www.w3.org/ns/activitystreams#", simple: true, prefix: true),
      "manuallyApprovesFollowers" => TermDefinition.new("manuallyApprovesFollowers", id: "https://www.w3.org/ns/activitystreams#manuallyApprovesFollowers", type_mapping: "http://www.w3.org/2001/XMLSchema#boolean"),
      "movedTo" => TermDefinition.new("movedTo", id: "https://www.w3.org/ns/activitystreams#movedTo", type_mapping: "@id"),
      "sensitive" => TermDefinition.new("sensitive", id: "https://www.w3.org/ns/activitystreams#sensitive", type_mapping: "http://www.w3.org/2001/XMLSchema#boolean"),
      "xsd" => TermDefinition.new("xsd", id: "http://www.w3.org/2001/XMLSchema#", simple: true, prefix: true)
    })
  end
  alias_preloaded("https://purl.archive.org/socialweb/miscellany", "http://purl.archive.org/socialweb/miscellany")
end
