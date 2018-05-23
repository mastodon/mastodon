# -*- encoding: utf-8 -*-
# frozen_string_literal: true
# This file generated automatically using rdf vocabulary format from http://www.w3.org/1999/02/22-rdf-syntax-ns#
require 'rdf'
module RDF
  # @!parse
  #   # Vocabulary for <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
  #   class RDFV < RDF::StrictVocabulary
  #   end
  class RDFV < RDF::StrictVocabulary("http://www.w3.org/1999/02/22-rdf-syntax-ns#")

    class << self
      def name; "RDF"; end
      alias_method :__name__, :name
    end

    # Ontology definition
    ontology :"http://www.w3.org/1999/02/22-rdf-syntax-ns#",
      "dc11:description": %(This is the RDF Schema for the RDF vocabulary terms in the RDF Namespace, defined in RDF 1.1 Concepts.).freeze,
      "dc11:title": %(The RDF Concepts Vocabulary \(RDF\)).freeze,
      type: "owl:Ontology".freeze

    # Class definitions
    term :Alt,
      comment: %(The class of containers of alternatives.).freeze,
      label: "Alt".freeze,
      isDefinedBy: %(rdf:).freeze,
      subClassOf: "rdfs:Container".freeze,
      type: "rdfs:Class".freeze
    term :Bag,
      comment: %(The class of unordered containers.).freeze,
      label: "Bag".freeze,
      isDefinedBy: %(rdf:).freeze,
      subClassOf: "rdfs:Container".freeze,
      type: "rdfs:Class".freeze
    term :List,
      comment: %(The class of RDF Lists.).freeze,
      label: "List".freeze,
      isDefinedBy: %(rdf:).freeze,
      subClassOf: "rdfs:Resource".freeze,
      type: "rdfs:Class".freeze
    term :Property,
      comment: %(The class of RDF properties.).freeze,
      label: "Property".freeze,
      isDefinedBy: %(rdf:).freeze,
      subClassOf: "rdfs:Resource".freeze,
      type: "rdfs:Class".freeze
    term :Seq,
      comment: %(The class of ordered containers.).freeze,
      label: "Seq".freeze,
      isDefinedBy: %(rdf:).freeze,
      subClassOf: "rdfs:Container".freeze,
      type: "rdfs:Class".freeze
    term :Statement,
      comment: %(The class of RDF statements.).freeze,
      label: "Statement".freeze,
      isDefinedBy: %(rdf:).freeze,
      subClassOf: "rdfs:Resource".freeze,
      type: "rdfs:Class".freeze

    # Property definitions
    property :first,
      comment: %(The first item in the subject RDF list.).freeze,
      domain: "rdf:List".freeze,
      label: "first".freeze,
      range: "rdfs:Resource".freeze,
      isDefinedBy: %(rdf:).freeze,
      type: "rdf:Property".freeze
    property :object,
      comment: %(The object of the subject RDF statement.).freeze,
      domain: "rdf:Statement".freeze,
      label: "object".freeze,
      range: "rdfs:Resource".freeze,
      isDefinedBy: %(rdf:).freeze,
      type: "rdf:Property".freeze
    property :predicate,
      comment: %(The predicate of the subject RDF statement.).freeze,
      domain: "rdf:Statement".freeze,
      label: "predicate".freeze,
      range: "rdfs:Resource".freeze,
      isDefinedBy: %(rdf:).freeze,
      type: "rdf:Property".freeze
    property :rest,
      comment: %(The rest of the subject RDF list after the first item.).freeze,
      domain: "rdf:List".freeze,
      label: "rest".freeze,
      range: "rdf:List".freeze,
      isDefinedBy: %(rdf:).freeze,
      type: "rdf:Property".freeze
    property :subject,
      comment: %(The subject of the subject RDF statement.).freeze,
      domain: "rdf:Statement".freeze,
      label: "subject".freeze,
      range: "rdfs:Resource".freeze,
      isDefinedBy: %(rdf:).freeze,
      type: "rdf:Property".freeze
    property :type,
      comment: %(The subject is an instance of a class.).freeze,
      domain: "rdfs:Resource".freeze,
      label: "type".freeze,
      range: "rdfs:Class".freeze,
      isDefinedBy: %(rdf:).freeze,
      type: "rdf:Property".freeze
    property :value,
      comment: %(Idiomatic property used for structured values.).freeze,
      domain: "rdfs:Resource".freeze,
      label: "value".freeze,
      range: "rdfs:Resource".freeze,
      isDefinedBy: %(rdf:).freeze,
      type: "rdf:Property".freeze

    # Datatype definitions
    term :HTML,
      comment: %(The datatype of RDF literals storing fragments of HTML content).freeze,
      label: "HTML".freeze,
      isDefinedBy: %(rdf:).freeze,
      "rdfs:seeAlso": %(http://www.w3.org/TR/rdf11-concepts/#section-html).freeze,
      subClassOf: "rdfs:Literal".freeze,
      type: "rdfs:Datatype".freeze
    term :PlainLiteral,
      comment: %(The class of plain \(i.e. untyped\) literal values, as used in RIF and OWL 2).freeze,
      label: "PlainLiteral".freeze,
      isDefinedBy: %(rdf:).freeze,
      "rdfs:seeAlso": %(http://www.w3.org/TR/rdf-plain-literal/).freeze,
      subClassOf: "rdfs:Literal".freeze,
      type: "rdfs:Datatype".freeze
    term :XMLLiteral,
      comment: %(The datatype of XML literal values.).freeze,
      label: "XMLLiteral".freeze,
      isDefinedBy: %(rdf:).freeze,
      subClassOf: "rdfs:Literal".freeze,
      type: "rdfs:Datatype".freeze
    term :langString,
      comment: %(The datatype of language-tagged string values).freeze,
      label: "langString".freeze,
      isDefinedBy: %(rdf:).freeze,
      "rdfs:seeAlso": %(http://www.w3.org/TR/rdf11-concepts/#section-Graph-Literal).freeze,
      subClassOf: "rdfs:Literal".freeze,
      type: "rdfs:Datatype".freeze

    # Extra definitions
   term :Description,
      comment: %(RDF/XML node element).freeze,
      label: "Description".freeze
    term :ID,
      comment: %(RDF/XML attribute creating a Reification).freeze,
      label: "ID".freeze
    term :about,
      comment: %(RDF/XML attribute declaring subject).freeze,
      label: "about".freeze
    term :datatype,
      comment: %(RDF/XML literal datatype).freeze,
      label: "datatype".freeze
    term :li,
      comment: %(RDF/XML container membership list element).freeze,
      label: "li".freeze
    term :nil,
      comment: %(The empty list, with no items in it. If the rest of a list is nil then the list has no more items in it.).freeze,
      label: "nil".freeze,
      isDefinedBy: %(rdf:).freeze,
      type: "rdf:List".freeze
    term :nodeID,
      comment: %(RDF/XML Blank Node identifier).freeze,
      label: "nodeID".freeze
    term :parseType,
      comment: %(Parse type for RDF/XML, either Collection, Literal or Resource).freeze,
      label: "parseType".freeze
    term :resource,
      comment: %(RDF/XML attribute declaring object).freeze,
      label: "resource".freeze
  end
end
