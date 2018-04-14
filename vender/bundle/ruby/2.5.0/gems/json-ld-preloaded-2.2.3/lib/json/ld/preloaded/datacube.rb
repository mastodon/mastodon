# -*- encoding: utf-8 -*-
# frozen_string_literal: true
# This file generated automatically from http://pebbie.org/context/qb
require 'json/ld'
class JSON::LD::Context
  add_preloaded("http://pebbie.org/context/qb") do
    new(processingMode: "json-ld-1.0", term_definitions: {
      "attribute" => TermDefinition.new("attribute", id: "http://purl.org/linked-data/cube#attribute", simple: true),
      "codeList" => TermDefinition.new("codeList", id: "http://purl.org/linked-data/cube#codeList", simple: true),
      "component" => TermDefinition.new("component", id: "http://purl.org/linked-data/cube#component", simple: true),
      "componentAttachment" => TermDefinition.new("componentAttachment", id: "http://purl.org/linked-data/cube#componentAttachment", simple: true),
      "componentProperty" => TermDefinition.new("componentProperty", id: "http://purl.org/linked-data/cube#componentProperty", simple: true),
      "componentRequired" => TermDefinition.new("componentRequired", id: "http://purl.org/linked-data/cube#componentRequired", type_mapping: "http://www.w3.org/2001/XMLSchema#boolean"),
      "concept" => TermDefinition.new("concept", id: "http://purl.org/linked-data/cube#concept", simple: true),
      "dataSet" => TermDefinition.new("dataSet", id: "http://purl.org/linked-data/cube#dataSet", simple: true),
      "dimension" => TermDefinition.new("dimension", id: "http://purl.org/linked-data/cube#dimension", simple: true),
      "hierarchyRoot" => TermDefinition.new("hierarchyRoot", id: "http://purl.org/linked-data/cube#hierarchyRoot", simple: true),
      "measure" => TermDefinition.new("measure", id: "http://purl.org/linked-data/cube#measure", simple: true),
      "measureDimension" => TermDefinition.new("measureDimension", id: "http://purl.org/linked-data/cube#measureDimension", simple: true),
      "measureType" => TermDefinition.new("measureType", id: "http://purl.org/linked-data/cube#measureType", simple: true),
      "observation" => TermDefinition.new("observation", id: "http://purl.org/linked-data/cube#observation", simple: true),
      "observationGroup" => TermDefinition.new("observationGroup", id: "http://purl.org/linked-data/cube#observationGroup", simple: true),
      "order" => TermDefinition.new("order", id: "http://purl.org/linked-data/cube#order", type_mapping: "http://www.w3.org/2001/XMLSchema#int"),
      "parentChildProperty" => TermDefinition.new("parentChildProperty", id: "http://purl.org/linked-data/cube#parentChildProperty", simple: true),
      "qb" => TermDefinition.new("qb", id: "http://purl.org/linked-data/cube#", simple: true, prefix: true),
      "qb:attribute" => TermDefinition.new("qb:attribute", id: "http://purl.org/linked-data/cube#attribute", type_mapping: "@id"),
      "qb:codeList" => TermDefinition.new("qb:codeList", id: "http://purl.org/linked-data/cube#codeList", type_mapping: "@id"),
      "qb:component" => TermDefinition.new("qb:component", id: "http://purl.org/linked-data/cube#component", type_mapping: "@id"),
      "qb:componentAttachment" => TermDefinition.new("qb:componentAttachment", id: "http://purl.org/linked-data/cube#componentAttachment", type_mapping: "@id"),
      "qb:componentProperty" => TermDefinition.new("qb:componentProperty", id: "http://purl.org/linked-data/cube#componentProperty", type_mapping: "@id"),
      "qb:concept" => TermDefinition.new("qb:concept", id: "http://purl.org/linked-data/cube#concept", type_mapping: "@id"),
      "qb:dataSet" => TermDefinition.new("qb:dataSet", id: "http://purl.org/linked-data/cube#dataSet", type_mapping: "@id"),
      "qb:dimension" => TermDefinition.new("qb:dimension", id: "http://purl.org/linked-data/cube#dimension", type_mapping: "@id"),
      "qb:hierarchyRoot" => TermDefinition.new("qb:hierarchyRoot", id: "http://purl.org/linked-data/cube#hierarchyRoot", type_mapping: "@id"),
      "qb:measure" => TermDefinition.new("qb:measure", id: "http://purl.org/linked-data/cube#measure", type_mapping: "@id"),
      "qb:measureDimension" => TermDefinition.new("qb:measureDimension", id: "http://purl.org/linked-data/cube#measureDimension", type_mapping: "@id"),
      "qb:measureType" => TermDefinition.new("qb:measureType", id: "http://purl.org/linked-data/cube#measureType", type_mapping: "@id"),
      "qb:observation" => TermDefinition.new("qb:observation", id: "http://purl.org/linked-data/cube#observation", type_mapping: "@id"),
      "qb:observationGroup" => TermDefinition.new("qb:observationGroup", id: "http://purl.org/linked-data/cube#observationGroup", type_mapping: "@id"),
      "qb:parentChildProperty" => TermDefinition.new("qb:parentChildProperty", id: "http://purl.org/linked-data/cube#parentChildProperty", type_mapping: "@id"),
      "qb:slice" => TermDefinition.new("qb:slice", id: "http://purl.org/linked-data/cube#slice", type_mapping: "@id"),
      "qb:sliceKey" => TermDefinition.new("qb:sliceKey", id: "http://purl.org/linked-data/cube#sliceKey", type_mapping: "@id"),
      "qb:sliceStructure" => TermDefinition.new("qb:sliceStructure", id: "http://purl.org/linked-data/cube#sliceStructure", type_mapping: "@id"),
      "qb:structure" => TermDefinition.new("qb:structure", id: "http://purl.org/linked-data/cube#structure", type_mapping: "@id"),
      "slice" => TermDefinition.new("slice", id: "http://purl.org/linked-data/cube#slice", simple: true),
      "sliceKey" => TermDefinition.new("sliceKey", id: "http://purl.org/linked-data/cube#sliceKey", simple: true),
      "sliceStructure" => TermDefinition.new("sliceStructure", id: "http://purl.org/linked-data/cube#sliceStructure", simple: true),
      "structure" => TermDefinition.new("structure", id: "http://purl.org/linked-data/cube#structure", simple: true),
      "xsd" => TermDefinition.new("xsd", id: "http://www.w3.org/2001/XMLSchema#", simple: true, prefix: true)
    })
  end
end
