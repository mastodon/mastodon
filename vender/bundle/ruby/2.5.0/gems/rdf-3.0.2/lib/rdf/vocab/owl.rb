# -*- encoding: utf-8 -*-
# frozen_string_literal: true
# This file generated automatically using rdf vocabulary format from http://www.w3.org/2002/07/owl#
require 'rdf'
module RDF
  # @!parse
  #   # Vocabulary for <http://www.w3.org/2002/07/owl#>
  #   class OWL < RDF::StrictVocabulary
  #   end
  class OWL < RDF::StrictVocabulary("http://www.w3.org/2002/07/owl#")

    # Ontology definition
    ontology :"http://www.w3.org/2002/07/owl",
      comment: %(
  This ontology partially describes the built-in classes and
  properties that together form the basis of the RDF/XML syntax of OWL 2.
  The content of this ontology is based on Tables 6.1 and 6.2
  in Section 6.4 of the OWL 2 RDF-Based Semantics specification,
  available at http://www.w3.org/TR/owl2-rdf-based-semantics/.
  Please note that those tables do not include the different annotations
  \(labels, comments and rdfs:isDefinedBy links\) used in this file.
  Also note that the descriptions provided in this ontology do not
  provide a complete and correct formal description of either the syntax
  or the semantics of the introduced terms \(please see the OWL 2
  recommendations for the complete and normative specifications\).
  Furthermore, the information provided by this ontology may be
  misleading if not used with care. This ontology SHOULD NOT be imported
  into OWL ontologies. Importing this file into an OWL 2 DL ontology
  will cause it to become an OWL 2 Full ontology and may have other,
  unexpected, consequences.
   ).freeze,
      "dc11:title": %(The OWL 2 Schema vocabulary \(OWL 2\)).freeze,
      "http://www.w3.org/2003/g/data-view#namespaceTransformation": %(http://dev.w3.org/cvsweb/2009/owl-grddl/owx2rdf.xsl).freeze,
      "owl:imports": %(http://www.w3.org/2000/01/rdf-schema).freeze,
      "owl:versionIRI": %(http://www.w3.org/2002/07/owl).freeze,
      "owl:versionInfo": %($Date: 2009/11/15 10:54:12 $).freeze,
      isDefinedBy: [%(http://www.w3.org/TR/owl2-mapping-to-rdf/).freeze, %(http://www.w3.org/TR/owl2-rdf-based-semantics/).freeze, %(http://www.w3.org/TR/owl2-syntax/).freeze],
      "rdfs:seeAlso": [%(http://www.w3.org/TR/owl2-rdf-based-semantics/#table-axiomatic-classes).freeze, %(http://www.w3.org/TR/owl2-rdf-based-semantics/#table-axiomatic-properties).freeze],
      type: "owl:Ontology".freeze

    # Class definitions
    term :AllDifferent,
      comment: %(The class of collections of pairwise different individuals.).freeze,
      label: "AllDifferent".freeze,
      isDefinedBy: %(owl:).freeze,
      subClassOf: "rdfs:Resource".freeze,
      type: "rdfs:Class".freeze
    term :AllDisjointClasses,
      comment: %(The class of collections of pairwise disjoint classes.).freeze,
      label: "AllDisjointClasses".freeze,
      isDefinedBy: %(owl:).freeze,
      subClassOf: "rdfs:Resource".freeze,
      type: "rdfs:Class".freeze
    term :AllDisjointProperties,
      comment: %(The class of collections of pairwise disjoint properties.).freeze,
      label: "AllDisjointProperties".freeze,
      isDefinedBy: %(owl:).freeze,
      subClassOf: "rdfs:Resource".freeze,
      type: "rdfs:Class".freeze
    term :Annotation,
      comment: %(The class of annotated annotations for which the RDF serialization consists of an annotated subject, predicate and object.).freeze,
      label: "Annotation".freeze,
      isDefinedBy: %(owl:).freeze,
      subClassOf: "rdfs:Resource".freeze,
      type: "rdfs:Class".freeze
    term :AnnotationProperty,
      comment: %(The class of annotation properties.).freeze,
      label: "AnnotationProperty".freeze,
      isDefinedBy: %(owl:).freeze,
      subClassOf: "rdf:Property".freeze,
      type: "rdfs:Class".freeze
    term :AsymmetricProperty,
      comment: %(The class of asymmetric properties.).freeze,
      label: "AsymmetricProperty".freeze,
      isDefinedBy: %(owl:).freeze,
      subClassOf: "owl:ObjectProperty".freeze,
      type: "rdfs:Class".freeze
    term :Axiom,
      comment: %(The class of annotated axioms for which the RDF serialization consists of an annotated subject, predicate and object.).freeze,
      label: "Axiom".freeze,
      isDefinedBy: %(owl:).freeze,
      subClassOf: "rdfs:Resource".freeze,
      type: "rdfs:Class".freeze
    term :Class,
      comment: %(The class of OWL classes.).freeze,
      label: "Class".freeze,
      isDefinedBy: %(owl:).freeze,
      subClassOf: "rdfs:Class".freeze,
      type: "rdfs:Class".freeze
    term :DataRange,
      comment: %(The class of OWL data ranges, which are special kinds of datatypes. Note: The use of the IRI owl:DataRange has been deprecated as of OWL 2. The IRI rdfs:Datatype SHOULD be used instead.).freeze,
      label: "DataRange".freeze,
      isDefinedBy: %(owl:).freeze,
      subClassOf: "rdfs:Datatype".freeze,
      type: "rdfs:Class".freeze
    term :DatatypeProperty,
      comment: %(The class of data properties.).freeze,
      label: "DatatypeProperty".freeze,
      isDefinedBy: %(owl:).freeze,
      subClassOf: "rdf:Property".freeze,
      type: "rdfs:Class".freeze
    term :DeprecatedClass,
      comment: %(The class of deprecated classes.).freeze,
      label: "DeprecatedClass".freeze,
      isDefinedBy: %(owl:).freeze,
      subClassOf: "rdfs:Class".freeze,
      type: "rdfs:Class".freeze
    term :DeprecatedProperty,
      comment: %(The class of deprecated properties.).freeze,
      label: "DeprecatedProperty".freeze,
      isDefinedBy: %(owl:).freeze,
      subClassOf: "rdf:Property".freeze,
      type: "rdfs:Class".freeze
    term :FunctionalProperty,
      comment: %(The class of functional properties.).freeze,
      label: "FunctionalProperty".freeze,
      isDefinedBy: %(owl:).freeze,
      subClassOf: "rdf:Property".freeze,
      type: "rdfs:Class".freeze
    term :InverseFunctionalProperty,
      comment: %(The class of inverse-functional properties.).freeze,
      label: "InverseFunctionalProperty".freeze,
      isDefinedBy: %(owl:).freeze,
      subClassOf: "owl:ObjectProperty".freeze,
      type: "rdfs:Class".freeze
    term :IrreflexiveProperty,
      comment: %(The class of irreflexive properties.).freeze,
      label: "IrreflexiveProperty".freeze,
      isDefinedBy: %(owl:).freeze,
      subClassOf: "owl:ObjectProperty".freeze,
      type: "rdfs:Class".freeze
    term :NamedIndividual,
      comment: %(The class of named individuals.).freeze,
      label: "NamedIndividual".freeze,
      isDefinedBy: %(owl:).freeze,
      subClassOf: "owl:Thing".freeze,
      type: "rdfs:Class".freeze
    term :NegativePropertyAssertion,
      comment: %(The class of negative property assertions.).freeze,
      label: "NegativePropertyAssertion".freeze,
      isDefinedBy: %(owl:).freeze,
      subClassOf: "rdfs:Resource".freeze,
      type: "rdfs:Class".freeze
    term :Nothing,
      comment: %(This is the empty class.).freeze,
      label: "Nothing".freeze,
      isDefinedBy: %(owl:).freeze,
      subClassOf: "owl:Thing".freeze,
      type: "owl:Class".freeze
    term :ObjectProperty,
      comment: %(The class of object properties.).freeze,
      label: "ObjectProperty".freeze,
      isDefinedBy: %(owl:).freeze,
      subClassOf: "rdf:Property".freeze,
      type: "rdfs:Class".freeze
    term :Ontology,
      comment: %(The class of ontologies.).freeze,
      label: "Ontology".freeze,
      isDefinedBy: %(owl:).freeze,
      subClassOf: "rdfs:Resource".freeze,
      type: "rdfs:Class".freeze
    term :OntologyProperty,
      comment: %(The class of ontology properties.).freeze,
      label: "OntologyProperty".freeze,
      isDefinedBy: %(owl:).freeze,
      subClassOf: "rdf:Property".freeze,
      type: "rdfs:Class".freeze
    term :ReflexiveProperty,
      comment: %(The class of reflexive properties.).freeze,
      label: "ReflexiveProperty".freeze,
      isDefinedBy: %(owl:).freeze,
      subClassOf: "owl:ObjectProperty".freeze,
      type: "rdfs:Class".freeze
    term :Restriction,
      comment: %(The class of property restrictions.).freeze,
      label: "Restriction".freeze,
      isDefinedBy: %(owl:).freeze,
      subClassOf: "owl:Class".freeze,
      type: "rdfs:Class".freeze
    term :SymmetricProperty,
      comment: %(The class of symmetric properties.).freeze,
      label: "SymmetricProperty".freeze,
      isDefinedBy: %(owl:).freeze,
      subClassOf: "owl:ObjectProperty".freeze,
      type: "rdfs:Class".freeze
    term :Thing,
      comment: %(The class of OWL individuals.).freeze,
      label: "Thing".freeze,
      isDefinedBy: %(owl:).freeze,
      type: "owl:Class".freeze
    term :TransitiveProperty,
      comment: %(The class of transitive properties.).freeze,
      label: "TransitiveProperty".freeze,
      isDefinedBy: %(owl:).freeze,
      subClassOf: "owl:ObjectProperty".freeze,
      type: "rdfs:Class".freeze

    # Property definitions
    property :allValuesFrom,
      comment: %(The property that determines the class that a universal property restriction refers to.).freeze,
      domain: "owl:Restriction".freeze,
      label: "allValuesFrom".freeze,
      range: "rdfs:Class".freeze,
      isDefinedBy: %(owl:).freeze,
      type: "rdf:Property".freeze
    property :annotatedProperty,
      comment: %(The property that determines the predicate of an annotated axiom or annotated annotation.).freeze,
      domain: "rdfs:Resource".freeze,
      label: "annotatedProperty".freeze,
      range: "rdfs:Resource".freeze,
      isDefinedBy: %(owl:).freeze,
      type: "rdf:Property".freeze
    property :annotatedSource,
      comment: %(The property that determines the subject of an annotated axiom or annotated annotation.).freeze,
      domain: "rdfs:Resource".freeze,
      label: "annotatedSource".freeze,
      range: "rdfs:Resource".freeze,
      isDefinedBy: %(owl:).freeze,
      type: "rdf:Property".freeze
    property :annotatedTarget,
      comment: %(The property that determines the object of an annotated axiom or annotated annotation.).freeze,
      domain: "rdfs:Resource".freeze,
      label: "annotatedTarget".freeze,
      range: "rdfs:Resource".freeze,
      isDefinedBy: %(owl:).freeze,
      type: "rdf:Property".freeze
    property :assertionProperty,
      comment: %(The property that determines the predicate of a negative property assertion.).freeze,
      domain: "owl:NegativePropertyAssertion".freeze,
      label: "assertionProperty".freeze,
      range: "rdf:Property".freeze,
      isDefinedBy: %(owl:).freeze,
      type: "rdf:Property".freeze
    property :backwardCompatibleWith,
      comment: %(The annotation property that indicates that a given ontology is backward compatible with another ontology.).freeze,
      domain: "owl:Ontology".freeze,
      label: "backwardCompatibleWith".freeze,
      range: "owl:Ontology".freeze,
      isDefinedBy: %(owl:).freeze,
      type: ["owl:AnnotationProperty".freeze, "owl:OntologyProperty".freeze]
    property :bottomDataProperty,
      comment: %(The data property that does not relate any individual to any data value.).freeze,
      domain: "owl:Thing".freeze,
      label: "bottomDataProperty".freeze,
      range: "rdfs:Literal".freeze,
      isDefinedBy: %(owl:).freeze,
      type: "owl:DatatypeProperty".freeze
    property :bottomObjectProperty,
      comment: %(The object property that does not relate any two individuals.).freeze,
      domain: "owl:Thing".freeze,
      label: "bottomObjectProperty".freeze,
      range: "owl:Thing".freeze,
      isDefinedBy: %(owl:).freeze,
      type: "owl:ObjectProperty".freeze
    property :cardinality,
      comment: %(The property that determines the cardinality of an exact cardinality restriction.).freeze,
      domain: "owl:Restriction".freeze,
      label: "cardinality".freeze,
      range: "xsd:nonNegativeInteger".freeze,
      isDefinedBy: %(owl:).freeze,
      type: "rdf:Property".freeze
    property :complementOf,
      comment: %(The property that determines that a given class is the complement of another class.).freeze,
      domain: "owl:Class".freeze,
      label: "complementOf".freeze,
      range: "owl:Class".freeze,
      isDefinedBy: %(owl:).freeze,
      type: "rdf:Property".freeze
    property :datatypeComplementOf,
      comment: %(The property that determines that a given data range is the complement of another data range with respect to the data domain.).freeze,
      domain: "rdfs:Datatype".freeze,
      label: "datatypeComplementOf".freeze,
      range: "rdfs:Datatype".freeze,
      isDefinedBy: %(owl:).freeze,
      type: "rdf:Property".freeze
    property :deprecated,
      comment: %(The annotation property that indicates that a given entity has been deprecated.).freeze,
      domain: "rdfs:Resource".freeze,
      label: "deprecated".freeze,
      range: "rdfs:Resource".freeze,
      isDefinedBy: %(owl:).freeze,
      type: "owl:AnnotationProperty".freeze
    property :differentFrom,
      comment: %(The property that determines that two given individuals are different.).freeze,
      domain: "owl:Thing".freeze,
      label: "differentFrom".freeze,
      range: "owl:Thing".freeze,
      isDefinedBy: %(owl:).freeze,
      type: "rdf:Property".freeze
    property :disjointUnionOf,
      comment: %(The property that determines that a given class is equivalent to the disjoint union of a collection of other classes.).freeze,
      domain: "owl:Class".freeze,
      label: "disjointUnionOf".freeze,
      range: "rdf:List".freeze,
      isDefinedBy: %(owl:).freeze,
      type: "rdf:Property".freeze
    property :disjointWith,
      comment: %(The property that determines that two given classes are disjoint.).freeze,
      domain: "owl:Class".freeze,
      label: "disjointWith".freeze,
      range: "owl:Class".freeze,
      isDefinedBy: %(owl:).freeze,
      type: "rdf:Property".freeze
    property :distinctMembers,
      comment: %(The property that determines the collection of pairwise different individuals in a owl:AllDifferent axiom.).freeze,
      domain: "owl:AllDifferent".freeze,
      label: "distinctMembers".freeze,
      range: "rdf:List".freeze,
      isDefinedBy: %(owl:).freeze,
      type: "rdf:Property".freeze
    property :equivalentClass,
      comment: %(The property that determines that two given classes are equivalent, and that is used to specify datatype definitions.).freeze,
      domain: "rdfs:Class".freeze,
      label: "equivalentClass".freeze,
      range: "rdfs:Class".freeze,
      isDefinedBy: %(owl:).freeze,
      type: "rdf:Property".freeze
    property :equivalentProperty,
      comment: %(The property that determines that two given properties are equivalent.).freeze,
      domain: "rdf:Property".freeze,
      label: "equivalentProperty".freeze,
      range: "rdf:Property".freeze,
      isDefinedBy: %(owl:).freeze,
      type: "rdf:Property".freeze
    property :hasKey,
      comment: %(The property that determines the collection of properties that jointly build a key.).freeze,
      domain: "owl:Class".freeze,
      label: "hasKey".freeze,
      range: "rdf:List".freeze,
      isDefinedBy: %(owl:).freeze,
      type: "rdf:Property".freeze
    property :hasSelf,
      comment: %(The property that determines the property that a self restriction refers to.).freeze,
      domain: "owl:Restriction".freeze,
      label: "hasSelf".freeze,
      range: "rdfs:Resource".freeze,
      isDefinedBy: %(owl:).freeze,
      type: "rdf:Property".freeze
    property :hasValue,
      comment: %(The property that determines the individual that a has-value restriction refers to.).freeze,
      domain: "owl:Restriction".freeze,
      label: "hasValue".freeze,
      range: "rdfs:Resource".freeze,
      isDefinedBy: %(owl:).freeze,
      type: "rdf:Property".freeze
    property :imports,
      comment: %(The property that is used for importing other ontologies into a given ontology.).freeze,
      domain: "owl:Ontology".freeze,
      label: "imports".freeze,
      range: "owl:Ontology".freeze,
      isDefinedBy: %(owl:).freeze,
      type: "owl:OntologyProperty".freeze
    property :incompatibleWith,
      comment: %(The annotation property that indicates that a given ontology is incompatible with another ontology.).freeze,
      domain: "owl:Ontology".freeze,
      label: "incompatibleWith".freeze,
      range: "owl:Ontology".freeze,
      isDefinedBy: %(owl:).freeze,
      type: ["owl:AnnotationProperty".freeze, "owl:OntologyProperty".freeze]
    property :intersectionOf,
      comment: %(The property that determines the collection of classes or data ranges that build an intersection.).freeze,
      domain: "rdfs:Class".freeze,
      label: "intersectionOf".freeze,
      range: "rdf:List".freeze,
      isDefinedBy: %(owl:).freeze,
      type: "rdf:Property".freeze
    property :inverseOf,
      comment: %(The property that determines that two given properties are inverse.).freeze,
      domain: "owl:ObjectProperty".freeze,
      label: "inverseOf".freeze,
      range: "owl:ObjectProperty".freeze,
      isDefinedBy: %(owl:).freeze,
      type: "rdf:Property".freeze
    property :maxCardinality,
      comment: %(The property that determines the cardinality of a maximum cardinality restriction.).freeze,
      domain: "owl:Restriction".freeze,
      label: "maxCardinality".freeze,
      range: "xsd:nonNegativeInteger".freeze,
      isDefinedBy: %(owl:).freeze,
      type: "rdf:Property".freeze
    property :maxQualifiedCardinality,
      comment: %(The property that determines the cardinality of a maximum qualified cardinality restriction.).freeze,
      domain: "owl:Restriction".freeze,
      label: "maxQualifiedCardinality".freeze,
      range: "xsd:nonNegativeInteger".freeze,
      isDefinedBy: %(owl:).freeze,
      type: "rdf:Property".freeze
    property :members,
      comment: %(The property that determines the collection of members in either a owl:AllDifferent, owl:AllDisjointClasses or owl:AllDisjointProperties axiom.).freeze,
      domain: "rdfs:Resource".freeze,
      label: "members".freeze,
      range: "rdf:List".freeze,
      isDefinedBy: %(owl:).freeze,
      type: "rdf:Property".freeze
    property :minCardinality,
      comment: %(The property that determines the cardinality of a minimum cardinality restriction.).freeze,
      domain: "owl:Restriction".freeze,
      label: "minCardinality".freeze,
      range: "xsd:nonNegativeInteger".freeze,
      isDefinedBy: %(owl:).freeze,
      type: "rdf:Property".freeze
    property :minQualifiedCardinality,
      comment: %(The property that determines the cardinality of a minimum qualified cardinality restriction.).freeze,
      domain: "owl:Restriction".freeze,
      label: "minQualifiedCardinality".freeze,
      range: "xsd:nonNegativeInteger".freeze,
      isDefinedBy: %(owl:).freeze,
      type: "rdf:Property".freeze
    property :onClass,
      comment: %(The property that determines the class that a qualified object cardinality restriction refers to.).freeze,
      domain: "owl:Restriction".freeze,
      label: "onClass".freeze,
      range: "owl:Class".freeze,
      isDefinedBy: %(owl:).freeze,
      type: "rdf:Property".freeze
    property :onDataRange,
      comment: %(The property that determines the data range that a qualified data cardinality restriction refers to.).freeze,
      domain: "owl:Restriction".freeze,
      label: "onDataRange".freeze,
      range: "rdfs:Datatype".freeze,
      isDefinedBy: %(owl:).freeze,
      type: "rdf:Property".freeze
    property :onDatatype,
      comment: %(The property that determines the datatype that a datatype restriction refers to.).freeze,
      domain: "rdfs:Datatype".freeze,
      label: "onDatatype".freeze,
      range: "rdfs:Datatype".freeze,
      isDefinedBy: %(owl:).freeze,
      type: "rdf:Property".freeze
    property :onProperties,
      comment: %(The property that determines the n-tuple of properties that a property restriction on an n-ary data range refers to.).freeze,
      domain: "owl:Restriction".freeze,
      label: "onProperties".freeze,
      range: "rdf:List".freeze,
      isDefinedBy: %(owl:).freeze,
      type: "rdf:Property".freeze
    property :onProperty,
      comment: %(The property that determines the property that a property restriction refers to.).freeze,
      domain: "owl:Restriction".freeze,
      label: "onProperty".freeze,
      range: "rdf:Property".freeze,
      isDefinedBy: %(owl:).freeze,
      type: "rdf:Property".freeze
    property :oneOf,
      comment: %(The property that determines the collection of individuals or data values that build an enumeration.).freeze,
      domain: "rdfs:Class".freeze,
      label: "oneOf".freeze,
      range: "rdf:List".freeze,
      isDefinedBy: %(owl:).freeze,
      type: "rdf:Property".freeze
    property :priorVersion,
      comment: %(The annotation property that indicates the predecessor ontology of a given ontology.).freeze,
      domain: "owl:Ontology".freeze,
      label: "priorVersion".freeze,
      range: "owl:Ontology".freeze,
      isDefinedBy: %(owl:).freeze,
      type: ["owl:AnnotationProperty".freeze, "owl:OntologyProperty".freeze]
    property :propertyChainAxiom,
      comment: %(The property that determines the n-tuple of properties that build a sub property chain of a given property.).freeze,
      domain: "owl:ObjectProperty".freeze,
      label: "propertyChainAxiom".freeze,
      range: "rdf:List".freeze,
      isDefinedBy: %(owl:).freeze,
      type: "rdf:Property".freeze
    property :propertyDisjointWith,
      comment: %(The property that determines that two given properties are disjoint.).freeze,
      domain: "rdf:Property".freeze,
      label: "propertyDisjointWith".freeze,
      range: "rdf:Property".freeze,
      isDefinedBy: %(owl:).freeze,
      type: "rdf:Property".freeze
    property :qualifiedCardinality,
      comment: %(The property that determines the cardinality of an exact qualified cardinality restriction.).freeze,
      domain: "owl:Restriction".freeze,
      label: "qualifiedCardinality".freeze,
      range: "xsd:nonNegativeInteger".freeze,
      isDefinedBy: %(owl:).freeze,
      type: "rdf:Property".freeze
    property :sameAs,
      comment: %(The property that determines that two given individuals are equal.).freeze,
      domain: "owl:Thing".freeze,
      label: "sameAs".freeze,
      range: "owl:Thing".freeze,
      isDefinedBy: %(owl:).freeze,
      type: "rdf:Property".freeze
    property :someValuesFrom,
      comment: %(The property that determines the class that an existential property restriction refers to.).freeze,
      domain: "owl:Restriction".freeze,
      label: "someValuesFrom".freeze,
      range: "rdfs:Class".freeze,
      isDefinedBy: %(owl:).freeze,
      type: "rdf:Property".freeze
    property :sourceIndividual,
      comment: %(The property that determines the subject of a negative property assertion.).freeze,
      domain: "owl:NegativePropertyAssertion".freeze,
      label: "sourceIndividual".freeze,
      range: "owl:Thing".freeze,
      isDefinedBy: %(owl:).freeze,
      type: "rdf:Property".freeze
    property :targetIndividual,
      comment: %(The property that determines the object of a negative object property assertion.).freeze,
      domain: "owl:NegativePropertyAssertion".freeze,
      label: "targetIndividual".freeze,
      range: "owl:Thing".freeze,
      isDefinedBy: %(owl:).freeze,
      type: "rdf:Property".freeze
    property :targetValue,
      comment: %(The property that determines the value of a negative data property assertion.).freeze,
      domain: "owl:NegativePropertyAssertion".freeze,
      label: "targetValue".freeze,
      range: "rdfs:Literal".freeze,
      isDefinedBy: %(owl:).freeze,
      type: "rdf:Property".freeze
    property :topDataProperty,
      comment: %(The data property that relates every individual to every data value.).freeze,
      domain: "owl:Thing".freeze,
      label: "topDataProperty".freeze,
      range: "rdfs:Literal".freeze,
      isDefinedBy: %(owl:).freeze,
      type: "owl:DatatypeProperty".freeze
    property :topObjectProperty,
      comment: %(The object property that relates every two individuals.).freeze,
      domain: "owl:Thing".freeze,
      label: "topObjectProperty".freeze,
      range: "owl:Thing".freeze,
      isDefinedBy: %(owl:).freeze,
      type: "owl:ObjectProperty".freeze
    property :unionOf,
      comment: %(The property that determines the collection of classes or data ranges that build a union.).freeze,
      domain: "rdfs:Class".freeze,
      label: "unionOf".freeze,
      range: "rdf:List".freeze,
      isDefinedBy: %(owl:).freeze,
      type: "rdf:Property".freeze
    property :versionIRI,
      comment: %(The property that identifies the version IRI of an ontology.).freeze,
      domain: "owl:Ontology".freeze,
      label: "versionIRI".freeze,
      range: "owl:Ontology".freeze,
      isDefinedBy: %(owl:).freeze,
      type: "owl:OntologyProperty".freeze
    property :versionInfo,
      comment: %(The annotation property that provides version information for an ontology or another OWL construct.).freeze,
      domain: "rdfs:Resource".freeze,
      label: "versionInfo".freeze,
      range: "rdfs:Resource".freeze,
      isDefinedBy: %(owl:).freeze,
      type: "owl:AnnotationProperty".freeze
    property :withRestrictions,
      comment: %(The property that determines the collection of facet-value pairs that define a datatype restriction.).freeze,
      domain: "rdfs:Datatype".freeze,
      label: "withRestrictions".freeze,
      range: "rdf:List".freeze,
      isDefinedBy: %(owl:).freeze,
      type: "rdf:Property".freeze
  end
end
