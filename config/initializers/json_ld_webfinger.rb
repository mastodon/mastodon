# frozen_string_literal: true

require 'json/ld'

class JSON::LD::Context
  add_preloaded("http://purl.archive.org/socialweb/webfinger") do
    new(processingMode: "json-ld-1.0", term_definitions: {
      "webfinger" => TermDefinition.new("webfinger", id: "https://purl.archive.org/socialweb/webfinger#webfinger", type_mapping: "http://www.w3.org/2001/XMLSchema#string"),
      "wf" => TermDefinition.new("wf", id: "https://purl.archive.org/socialweb/webfinger#", simple: true, prefix: true),
      "xsd" => TermDefinition.new("xsd", id: "http://www.w3.org/2001/XMLSchema#", simple: true, prefix: true)
    })
  end
  alias_preloaded("https://purl.archive.org/socialweb/webfinger", "http://purl.archive.org/socialweb/webfinger")
end
