# -*- encoding: utf-8 -*-
# frozen_string_literal: true
# This file generated automatically from https://www.w3.org/ns/cid/v1

require 'json/ld'

class JSON::LD::Context
  add_preloaded("http://www.w3.org/ns/cid/v1") do
    new(processingMode: "json-ld-1.1", term_definitions: {
      "JsonWebKey" => TermDefinition.new("JsonWebKey", id: "https://w3id.org/security#JsonWebKey", context: {"@protected" => true, "id" => "@id", "type" => "@type", "controller" => {"@id" => "https://w3id.org/security#controller", "@type" => "@id"}, "revoked" => {"@id" => "https://w3id.org/security#revoked", "@type" => "http://www.w3.org/2001/XMLSchema#dateTime"}, "expires" => {"@id" => "https://w3id.org/security#expiration", "@type" => "http://www.w3.org/2001/XMLSchema#dateTime"}, "publicKeyJwk" => {"@id" => "https://w3id.org/security#publicKeyJwk", "@type" => "@json"}, "secretKeyJwk" => {"@id" => "https://w3id.org/security#secretKeyJwk", "@type" => "@json"}}, protected: true),
      "Multikey" => TermDefinition.new("Multikey", id: "https://w3id.org/security#Multikey", context: {"@protected" => true, "id" => "@id", "type" => "@type", "controller" => {"@id" => "https://w3id.org/security#controller", "@type" => "@id"}, "revoked" => {"@id" => "https://w3id.org/security#revoked", "@type" => "http://www.w3.org/2001/XMLSchema#dateTime"}, "expires" => {"@id" => "https://w3id.org/security#expiration", "@type" => "http://www.w3.org/2001/XMLSchema#dateTime"}, "publicKeyMultibase" => {"@id" => "https://w3id.org/security#publicKeyMultibase", "@type" => "https://w3id.org/security#multibase"}, "secretKeyMultibase" => {"@id" => "https://w3id.org/security#secretKeyMultibase", "@type" => "https://w3id.org/security#multibase"}}, protected: true),
      "alsoKnownAs" => TermDefinition.new("alsoKnownAs", id: "https://www.w3.org/ns/activitystreams#alsoKnownAs", type_mapping: "@id", protected: true),
      "assertionMethod" => TermDefinition.new("assertionMethod", id: "https://w3id.org/security#assertionMethod", type_mapping: "@id", container_mapping: "@set", protected: true),
      "authentication" => TermDefinition.new("authentication", id: "https://w3id.org/security#authenticationMethod", type_mapping: "@id", container_mapping: "@set", protected: true),
      "capabilityDelegation" => TermDefinition.new("capabilityDelegation", id: "https://w3id.org/security#capabilityDelegationMethod", type_mapping: "@id", container_mapping: "@set", protected: true),
      "capabilityInvocation" => TermDefinition.new("capabilityInvocation", id: "https://w3id.org/security#capabilityInvocationMethod", type_mapping: "@id", container_mapping: "@set", protected: true),
      "controller" => TermDefinition.new("controller", id: "https://w3id.org/security#controller", type_mapping: "@id", protected: true),
      "id" => TermDefinition.new("id", id: "@id", simple: true, protected: true),
      "keyAgreement" => TermDefinition.new("keyAgreement", id: "https://w3id.org/security#keyAgreementMethod", type_mapping: "@id", container_mapping: "@set", protected: true),
      "service" => TermDefinition.new("service", id: "https://www.w3.org/ns/did#service", type_mapping: "@id", context: {"@protected" => true, "id" => "@id", "type" => "@type", "serviceEndpoint" => {"@id" => "https://www.w3.org/ns/did#serviceEndpoint", "@type" => "@id"}}, protected: true),
      "type" => TermDefinition.new("type", id: "@type", simple: true, protected: true),
      "verificationMethod" => TermDefinition.new("verificationMethod", id: "https://w3id.org/security#verificationMethod", type_mapping: "@id", protected: true)
    })
  end
  alias_preloaded("https://www.w3.org/ns/cid/v1", "http://www.w3.org/ns/cid/v1")
end
