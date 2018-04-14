# -*- encoding: utf-8 -*-
# frozen_string_literal: true
$:.unshift(File.expand_path("../ld", __FILE__))
require 'rdf' # @see http://rubygems.org/gems/rdf
require 'multi_json'
require 'set'

module JSON
  ##
  # **`JSON::LD`** is a JSON-LD extension for RDF.rb.
  #
  # @example Requiring the `JSON::LD` module
  #   require 'json/ld'
  #
  # @example Parsing RDF statements from a JSON-LD file
  #   JSON::LD::Reader.open("etc/foaf.jld") do |reader|
  #     reader.each_statement do |statement|
  #       puts statement.inspect
  #     end
  #   end
  #
  # @see http://rubygems.org/gems/rdf
  # @see http://www.w3.org/TR/REC-rdf-syntax/
  #
  # @author [Gregg Kellogg](http://greggkellogg.net/)
  module LD
    require 'json'
    require 'json/ld/extensions'
    require 'json/ld/format'
    require 'json/ld/utils'
    autoload :API,                'json/ld/api'
    autoload :Context,            'json/ld/context'
    autoload :Normalize,          'json/ld/normalize'
    autoload :Reader,             'json/ld/reader'
    autoload :Resource,           'json/ld/resource'
    autoload :VERSION,            'json/ld/version'
    autoload :Writer,             'json/ld/writer'

    # Initial context
    # @see http://json-ld.org/spec/latest/json-ld-api/#appendix-b
    INITIAL_CONTEXT = {
      RDF.type.to_s => {"@type" => "@id"}
    }.freeze

    KEYWORDS = Set.new(%w(
      @base
      @container
      @context
      @default
      @embed
      @explicit
      @id
      @index
      @graph
      @language
      @list
      @nest
      @omitDefault
      @requireAll
      @reverse
      @set
      @type
      @value
      @version
      @vocab
    )).freeze

    # Regexp matching an NCName.
    NC_REGEXP = Regexp.new(
      %{^
        (?!\\\\u0301)             # &#x301; is a non-spacing acute accent.
                                  # It is legal within an XML Name, but not as the first character.
        (  [a-zA-Z_]
         | \\\\u[0-9a-fA-F]
        )
        (  [0-9a-zA-Z_\.-]
         | \\\\u([0-9a-fA-F]{4})
        )*
      $},
      Regexp::EXTENDED)

    # Datatypes that are expressed in a native form and don't expand or compact
    NATIVE_DATATYPES = [RDF::XSD.integer.to_s, RDF::XSD.boolean.to_s, RDF::XSD.double.to_s]

    JSON_STATE = JSON::State.new(
      indent:       "  ",
      space:        " ",
      space_before: "",
      object_nl:    "\n",
      array_nl:     "\n"
    )

    class JsonLdError < StandardError
      def to_s
        "#{self.class.instance_variable_get :@code}: #{super}"
      end
      def code
        self.class.instance_variable_get :@code
      end

      class CollidingKeywords < JsonLdError; @code = "colliding keywords"; end
      class CompactionToListOfLists < JsonLdError; @code = "compaction to list of lists"; end
      class ConflictingIndexes < JsonLdError; @code = "conflicting indexes"; end
      class CyclicIRIMapping < JsonLdError; @code = "cyclic IRI mapping"; end
      class InvalidBaseIRI < JsonLdError; @code = "invalid base IRI"; end
      class InvalidContainerMapping < JsonLdError; @code = "invalid container mapping"; end
      class InvalidDefaultLanguage < JsonLdError; @code = "invalid default language"; end
      class InvalidIdValue < JsonLdError; @code = "invalid @id value"; end
      class InvalidIndexValue < JsonLdError; @code = "invalid @index value"; end
      class InvalidVersionValue < JsonLdError; @code = "invalid @version value"; end
      class InvalidIRIMapping < JsonLdError; @code = "invalid IRI mapping"; end
      class InvalidKeywordAlias < JsonLdError; @code = "invalid keyword alias"; end
      class InvalidLanguageMapping < JsonLdError; @code = "invalid language mapping"; end
      class InvalidLanguageMapValue < JsonLdError; @code = "invalid language map value"; end
      class InvalidLanguageTaggedString < JsonLdError; @code = "invalid language-tagged string"; end
      class InvalidLanguageTaggedValue < JsonLdError; @code = "invalid language-tagged value"; end
      class InvalidLocalContext < JsonLdError; @code = "invalid local context"; end
      class InvalidNestValue < JsonLdError; @code = "invalid @nest value"; end
      class InvalidPrefixValue < JsonLdError; @code = "invalid @prefix value"; end
      class InvalidRemoteContext < JsonLdError; @code = "invalid remote context"; end
      class InvalidReverseProperty < JsonLdError; @code = "invalid reverse property"; end
      class InvalidReversePropertyMap < JsonLdError; @code = "invalid reverse property map"; end
      class InvalidReversePropertyValue < JsonLdError; @code = "invalid reverse property value"; end
      class InvalidReverseValue < JsonLdError; @code = "invalid @reverse value"; end
      class InvalidScopedContext < JsonLdError; @code = "invalid scoped context"; end
      class InvalidSetOrListObject < JsonLdError; @code = "invalid set or list object"; end
      class InvalidTermDefinition < JsonLdError; @code = "invalid term definition"; end
      class InvalidTypedValue < JsonLdError; @code = "invalid typed value"; end
      class InvalidTypeMapping < JsonLdError; @code = "invalid type mapping"; end
      class InvalidTypeValue < JsonLdError; @code = "invalid type value"; end
      class InvalidValueObject < JsonLdError; @code = "invalid value object"; end
      class InvalidValueObjectValue < JsonLdError; @code = "invalid value object value"; end
      class InvalidVocabMapping < JsonLdError; @code = "invalid vocab mapping"; end
      class KeywordRedefinition < JsonLdError; @code = "keyword redefinition"; end
      class ListOfLists < JsonLdError; @code = "list of lists"; end
      class LoadingDocumentFailed < JsonLdError; @code = "loading document failed"; end
      class LoadingRemoteContextFailed < JsonLdError; @code = "loading remote context failed"; end
      class MultipleContextLinkHeaders < JsonLdError; @code = "multiple context link headers"; end
      class ProcessingModeConflict < JsonLdError; @code = "processing mode conflict"; end
      class RecursiveContextInclusion < JsonLdError; @code = "recursive context inclusion"; end
      class InvalidFrame < JsonLdError
        class MultipleEmbeds < InvalidFrame; end
        class Syntax < InvalidFrame; end
      end
    end
  end
end
