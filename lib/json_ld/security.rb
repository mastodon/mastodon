# -*- encoding: utf-8 -*-
# frozen_string_literal: true
# This file generated automatically from https://w3id.org/security/v1
require 'json/ld'
class JSON::LD::Context
  add_preloaded("https://w3id.org/security/v1") do
    new(processingMode: "json-ld-1.0", term_definitions: {
      "CryptographicKey" => TermDefinition.new("CryptographicKey", id: "https://w3id.org/security#Key", simple: true),
      "EcdsaKoblitzSignature2016" => TermDefinition.new("EcdsaKoblitzSignature2016", id: "https://w3id.org/security#EcdsaKoblitzSignature2016", simple: true),
      "EncryptedMessage" => TermDefinition.new("EncryptedMessage", id: "https://w3id.org/security#EncryptedMessage", simple: true),
      "GraphSignature2012" => TermDefinition.new("GraphSignature2012", id: "https://w3id.org/security#GraphSignature2012", simple: true),
      "LinkedDataSignature2015" => TermDefinition.new("LinkedDataSignature2015", id: "https://w3id.org/security#LinkedDataSignature2015", simple: true),
      "LinkedDataSignature2016" => TermDefinition.new("LinkedDataSignature2016", id: "https://w3id.org/security#LinkedDataSignature2016", simple: true),
      "authenticationTag" => TermDefinition.new("authenticationTag", id: "https://w3id.org/security#authenticationTag", simple: true),
      "canonicalizationAlgorithm" => TermDefinition.new("canonicalizationAlgorithm", id: "https://w3id.org/security#canonicalizationAlgorithm", simple: true),
      "cipherAlgorithm" => TermDefinition.new("cipherAlgorithm", id: "https://w3id.org/security#cipherAlgorithm", simple: true),
      "cipherData" => TermDefinition.new("cipherData", id: "https://w3id.org/security#cipherData", simple: true),
      "cipherKey" => TermDefinition.new("cipherKey", id: "https://w3id.org/security#cipherKey", simple: true),
      "created" => TermDefinition.new("created", id: "http://purl.org/dc/terms/created", type_mapping: "http://www.w3.org/2001/XMLSchema#dateTime"),
      "creator" => TermDefinition.new("creator", id: "http://purl.org/dc/terms/creator", type_mapping: "@id"),
      "dc" => TermDefinition.new("dc", id: "http://purl.org/dc/terms/", simple: true, prefix: true),
      "digestAlgorithm" => TermDefinition.new("digestAlgorithm", id: "https://w3id.org/security#digestAlgorithm", simple: true),
      "digestValue" => TermDefinition.new("digestValue", id: "https://w3id.org/security#digestValue", simple: true),
      "domain" => TermDefinition.new("domain", id: "https://w3id.org/security#domain", simple: true),
      "encryptionKey" => TermDefinition.new("encryptionKey", id: "https://w3id.org/security#encryptionKey", simple: true),
      "expiration" => TermDefinition.new("expiration", id: "https://w3id.org/security#expiration", type_mapping: "http://www.w3.org/2001/XMLSchema#dateTime"),
      "expires" => TermDefinition.new("expires", id: "https://w3id.org/security#expiration", type_mapping: "http://www.w3.org/2001/XMLSchema#dateTime"),
      "id" => TermDefinition.new("id", id: "@id", simple: true),
      "initializationVector" => TermDefinition.new("initializationVector", id: "https://w3id.org/security#initializationVector", simple: true),
      "iterationCount" => TermDefinition.new("iterationCount", id: "https://w3id.org/security#iterationCount", simple: true),
      "nonce" => TermDefinition.new("nonce", id: "https://w3id.org/security#nonce", simple: true),
      "normalizationAlgorithm" => TermDefinition.new("normalizationAlgorithm", id: "https://w3id.org/security#normalizationAlgorithm", simple: true),
      "owner" => TermDefinition.new("owner", id: "https://w3id.org/security#owner", type_mapping: "@id"),
      "password" => TermDefinition.new("password", id: "https://w3id.org/security#password", simple: true),
      "privateKey" => TermDefinition.new("privateKey", id: "https://w3id.org/security#privateKey", type_mapping: "@id"),
      "privateKeyPem" => TermDefinition.new("privateKeyPem", id: "https://w3id.org/security#privateKeyPem", simple: true),
      "publicKey" => TermDefinition.new("publicKey", id: "https://w3id.org/security#publicKey", type_mapping: "@id"),
      "publicKeyPem" => TermDefinition.new("publicKeyPem", id: "https://w3id.org/security#publicKeyPem", simple: true),
      "publicKeyService" => TermDefinition.new("publicKeyService", id: "https://w3id.org/security#publicKeyService", type_mapping: "@id"),
      "revoked" => TermDefinition.new("revoked", id: "https://w3id.org/security#revoked", type_mapping: "http://www.w3.org/2001/XMLSchema#dateTime"),
      "salt" => TermDefinition.new("salt", id: "https://w3id.org/security#salt", simple: true),
      "sec" => TermDefinition.new("sec", id: "https://w3id.org/security#", simple: true, prefix: true),
      "signature" => TermDefinition.new("signature", id: "https://w3id.org/security#signature", simple: true),
      "signatureAlgorithm" => TermDefinition.new("signatureAlgorithm", id: "https://w3id.org/security#signingAlgorithm", simple: true),
      "signatureValue" => TermDefinition.new("signatureValue", id: "https://w3id.org/security#signatureValue", simple: true),
      "type" => TermDefinition.new("type", id: "@type", simple: true),
      "xsd" => TermDefinition.new("xsd", id: "http://www.w3.org/2001/XMLSchema#", simple: true, prefix: true)
    })
  end
end
