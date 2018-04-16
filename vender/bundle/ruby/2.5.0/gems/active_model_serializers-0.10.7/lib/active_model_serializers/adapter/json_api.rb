# {http://jsonapi.org/format/ JSON API specification}
# rubocop:disable Style/AsciiComments
# TODO: implement!
#  ☐ https://github.com/rails-api/active_model_serializers/issues/1235
# TODO: use uri_template in link generation?
#  ☐ https://github.com/rails-api/active_model_serializers/pull/1282#discussion_r42528812
#    see gem https://github.com/hannesg/uri_template
#    spec http://tools.ietf.org/html/rfc6570
#    impl https://developer.github.com/v3/#schema https://api.github.com/
# TODO: validate against a JSON schema document?
#  ☐ https://github.com/rails-api/active_model_serializers/issues/1162
#  ☑ https://github.com/rails-api/active_model_serializers/pull/1270
# TODO: Routing
#  ☐ https://github.com/rails-api/active_model_serializers/pull/1476
# TODO: Query Params
#  ☑ `include` https://github.com/rails-api/active_model_serializers/pull/1131
#  ☑ `fields` https://github.com/rails-api/active_model_serializers/pull/700
#  ☑ `page[number]=3&page[size]=1` https://github.com/rails-api/active_model_serializers/pull/1041
#  ☐ `filter`
#  ☐ `sort`
module ActiveModelSerializers
  module Adapter
    class JsonApi < Base
      extend ActiveSupport::Autoload
      autoload :Jsonapi
      autoload :ResourceIdentifier
      autoload :Relationship
      autoload :Link
      autoload :PaginationLinks
      autoload :Meta
      autoload :Error
      autoload :Deserialization

      def self.default_key_transform
        :dash
      end

      def self.fragment_cache(cached_hash, non_cached_hash, root = true)
        core_cached       = cached_hash.first
        core_non_cached   = non_cached_hash.first
        no_root_cache     = cached_hash.delete_if { |key, _value| key == core_cached[0] }
        no_root_non_cache = non_cached_hash.delete_if { |key, _value| key == core_non_cached[0] }
        cached_resource   = (core_cached[1]) ? core_cached[1].deep_merge(core_non_cached[1]) : core_non_cached[1]
        hash = root ? { root => cached_resource } : cached_resource

        hash.deep_merge no_root_non_cache.deep_merge no_root_cache
      end

      def initialize(serializer, options = {})
        super
        @include_directive = JSONAPI::IncludeDirective.new(options[:include], allow_wildcard: true)
        @fieldset = options[:fieldset] || ActiveModel::Serializer::Fieldset.new(options.delete(:fields))
      end

      # {http://jsonapi.org/format/#crud Requests are transactional, i.e. success or failure}
      # {http://jsonapi.org/format/#document-top-level data and errors MUST NOT coexist in the same document.}
      def serializable_hash(*)
        document = if serializer.success?
                     success_document
                   else
                     failure_document
                   end
        self.class.transform_key_casing!(document, instance_options)
      end

      def fragment_cache(cached_hash, non_cached_hash)
        root = !instance_options.include?(:include)
        self.class.fragment_cache(cached_hash, non_cached_hash, root)
      end

      # {http://jsonapi.org/format/#document-top-level Primary data}
      # definition:
      #   ☐ toplevel_data (required)
      #   ☐ toplevel_included
      #   ☑ toplevel_meta
      #   ☑ toplevel_links
      #   ☑ toplevel_jsonapi
      # structure:
      #  {
      #    data: toplevel_data,
      #    included: toplevel_included,
      #    meta: toplevel_meta,
      #    links: toplevel_links,
      #    jsonapi: toplevel_jsonapi
      #  }.reject! {|_,v| v.nil? }
      # rubocop:disable Metrics/CyclomaticComplexity
      def success_document
        is_collection = serializer.respond_to?(:each)
        serializers = is_collection ? serializer : [serializer]
        primary_data, included = resource_objects_for(serializers)

        hash = {}
        # toplevel_data
        # definition:
        #   oneOf
        #     resource
        #     array of unique items of type 'resource'
        #     null
        #
        # description:
        #   The document's "primary data" is a representation of the resource or collection of resources
        #   targeted by a request.
        #
        #   Singular: the resource object.
        #
        #   Collection: one of an array of resource objects, an array of resource identifier objects, or
        #   an empty array ([]), for requests that target resource collections.
        #
        #   None: null if the request is one that might correspond to a single resource, but doesn't currently.
        # structure:
        #  if serializable_resource.resource?
        #    resource
        #  elsif serializable_resource.collection?
        #    [
        #      resource,
        #      resource
        #    ]
        #  else
        #    nil
        #  end
        hash[:data] = is_collection ? primary_data : primary_data[0]
        # toplevel_included
        #   alias included
        # definition:
        #   array of unique items of type 'resource'
        #
        # description:
        #   To reduce the number of HTTP requests, servers **MAY** allow
        #   responses that include related resources along with the requested primary
        #   resources. Such responses are called "compound documents".
        # structure:
        #     [
        #       resource,
        #       resource
        #     ]
        hash[:included] = included if included.any?

        Jsonapi.add!(hash)

        if instance_options[:links]
          hash[:links] ||= {}
          hash[:links].update(instance_options[:links])
        end

        if is_collection && serializer.paginated?
          hash[:links] ||= {}
          hash[:links].update(pagination_links_for(serializer))
        end

        hash[:meta] = instance_options[:meta] unless instance_options[:meta].blank?

        hash
      end
      # rubocop:enable Metrics/CyclomaticComplexity

      # {http://jsonapi.org/format/#errors JSON API Errors}
      # TODO: look into caching
      # definition:
      #   ☑ toplevel_errors array (required)
      #   ☐ toplevel_meta
      #   ☐ toplevel_jsonapi
      # structure:
      #   {
      #     errors: toplevel_errors,
      #     meta: toplevel_meta,
      #     jsonapi: toplevel_jsonapi
      #   }.reject! {|_,v| v.nil? }
      # prs:
      #  https://github.com/rails-api/active_model_serializers/pull/1004
      def failure_document
        hash = {}
        # PR Please :)
        # Jsonapi.add!(hash)

        # toplevel_errors
        # definition:
        #   array of unique items of type 'error'
        # structure:
        #   [
        #     error,
        #     error
        #   ]
        if serializer.respond_to?(:each)
          hash[:errors] = serializer.flat_map do |error_serializer|
            Error.resource_errors(error_serializer, instance_options)
          end
        else
          hash[:errors] = Error.resource_errors(serializer, instance_options)
        end
        hash
      end

      protected

      attr_reader :fieldset

      private

      # {http://jsonapi.org/format/#document-resource-objects Primary data}
      # resource
      # definition:
      #   JSON Object
      #
      # properties:
      #   type (required) : String
      #   id   (required) : String
      #   attributes
      #   relationships
      #   links
      #   meta
      #
      # description:
      #   "Resource objects" appear in a JSON API document to represent resources
      # structure:
      #   {
      #     type: 'admin--some-user',
      #     id: '1336',
      #     attributes: attributes,
      #     relationships: relationships,
      #     links: links,
      #     meta: meta,
      #   }.reject! {|_,v| v.nil? }
      # prs:
      #   type
      #     https://github.com/rails-api/active_model_serializers/pull/1122
      #     [x] https://github.com/rails-api/active_model_serializers/pull/1213
      #     https://github.com/rails-api/active_model_serializers/pull/1216
      #     https://github.com/rails-api/active_model_serializers/pull/1029
      #   links
      #     [x] https://github.com/rails-api/active_model_serializers/pull/1246
      #     [x] url helpers https://github.com/rails-api/active_model_serializers/issues/1269
      #   meta
      #     [x] https://github.com/rails-api/active_model_serializers/pull/1340
      def resource_objects_for(serializers)
        @primary = []
        @included = []
        @resource_identifiers = Set.new
        serializers.each { |serializer| process_resource(serializer, true, @include_directive) }
        serializers.each { |serializer| process_relationships(serializer, @include_directive) }

        [@primary, @included]
      end

      def process_resource(serializer, primary, include_slice = {})
        resource_identifier = ResourceIdentifier.new(serializer, instance_options).as_json
        return false unless @resource_identifiers.add?(resource_identifier)

        resource_object = resource_object_for(serializer, include_slice)
        if primary
          @primary << resource_object
        else
          @included << resource_object
        end

        true
      end

      def process_relationships(serializer, include_slice)
        serializer.associations(include_slice).each do |association|
          # TODO(BF): Process relationship without evaluating lazy_association
          process_relationship(association.lazy_association.serializer, include_slice[association.key])
        end
      end

      def process_relationship(serializer, include_slice)
        if serializer.respond_to?(:each)
          serializer.each { |s| process_relationship(s, include_slice) }
          return
        end
        return unless serializer && serializer.object
        return unless process_resource(serializer, false, include_slice)

        process_relationships(serializer, include_slice)
      end

      # {http://jsonapi.org/format/#document-resource-object-attributes Document Resource Object Attributes}
      # attributes
      # definition:
      #   JSON Object
      #
      # patternProperties:
      #   ^(?!relationships$|links$)\\w[-\\w_]*$
      #
      # description:
      #   Members of the attributes object ("attributes") represent information about the resource
      #   object in which it's defined.
      #   Attributes may contain any valid JSON value
      # structure:
      #   {
      #     foo: 'bar'
      #   }
      def attributes_for(serializer, fields)
        serializer.attributes(fields).except(:id)
      end

      # {http://jsonapi.org/format/#document-resource-objects Document Resource Objects}
      def resource_object_for(serializer, include_slice = {})
        resource_object = data_for(serializer, include_slice)

        # toplevel_links
        # definition:
        #   allOf
        #      ☐ links
        #      ☐ pagination
        #
        # description:
        #  Link members related to the primary data.
        # structure:
        #   links.merge!(pagination)
        # prs:
        #   https://github.com/rails-api/active_model_serializers/pull/1247
        #   https://github.com/rails-api/active_model_serializers/pull/1018
        if (links = links_for(serializer)).any?
          resource_object ||= {}
          resource_object[:links] = links
        end

        # toplevel_meta
        #   alias meta
        # definition:
        #   meta
        # structure
        #   {
        #     :'git-ref' => 'abc123'
        #   }
        if (meta = meta_for(serializer)).present?
          resource_object ||= {}
          resource_object[:meta] = meta
        end

        resource_object
      end

      def data_for(serializer, include_slice)
        data = serializer.fetch(self) do
          resource_object = ResourceIdentifier.new(serializer, instance_options).as_json
          break nil if resource_object.nil?

          requested_fields = fieldset && fieldset.fields_for(resource_object[:type])
          attributes = attributes_for(serializer, requested_fields)
          resource_object[:attributes] = attributes if attributes.any?
          resource_object
        end
        data.tap do |resource_object|
          next if resource_object.nil?
          # NOTE(BF): the attributes are cached above, separately from the relationships, below.
          requested_associations = fieldset.fields_for(resource_object[:type]) || '*'
          relationships = relationships_for(serializer, requested_associations, include_slice)
          resource_object[:relationships] = relationships if relationships.any?
        end
      end

      # {http://jsonapi.org/format/#document-resource-object-relationships Document Resource Object Relationship}
      # relationships
      # definition:
      #   JSON Object
      #
      # patternProperties:
      #   ^\\w[-\\w_]*$"
      #
      # properties:
      #   data : relationshipsData
      #   links
      #   meta
      #
      # description:
      #
      #   Members of the relationships object ("relationships") represent references from the
      #   resource object in which it's defined to other resource objects."
      # structure:
      #   {
      #     links: links,
      #     meta: meta,
      #     data: relationshipsData
      #   }.reject! {|_,v| v.nil? }
      #
      # prs:
      #   links
      #     [x] https://github.com/rails-api/active_model_serializers/pull/1454
      #   meta
      #     [x] https://github.com/rails-api/active_model_serializers/pull/1454
      #   polymorphic
      #     [ ] https://github.com/rails-api/active_model_serializers/pull/1420
      #
      # relationshipsData
      # definition:
      #   oneOf
      #     relationshipToOne
      #     relationshipToMany
      #
      # description:
      #   Member, whose value represents "resource linkage"
      # structure:
      #   if has_one?
      #     relationshipToOne
      #   else
      #     relationshipToMany
      #   end
      #
      # definition:
      #   anyOf
      #     null
      #     linkage
      #
      # relationshipToOne
      # description:
      #
      #   References to other resource objects in a to-one ("relationship"). Relationships can be
      #   specified by including a member in a resource's links object.
      #
      #   None: Describes an empty to-one relationship.
      # structure:
      #   if has_related?
      #     linkage
      #   else
      #     nil
      #   end
      #
      # relationshipToMany
      # definition:
      #   array of unique items of type 'linkage'
      #
      # description:
      #   An array of objects each containing "type" and "id" members for to-many relationships
      # structure:
      #   [
      #     linkage,
      #     linkage
      #   ]
      # prs:
      #   polymorphic
      #     [ ] https://github.com/rails-api/active_model_serializers/pull/1282
      #
      # linkage
      # definition:
      #   type (required) : String
      #   id   (required) : String
      #   meta
      #
      # description:
      #   The "type" and "id" to non-empty members.
      # structure:
      #   {
      #     type: 'required-type',
      #     id: 'required-id',
      #     meta: meta
      #   }.reject! {|_,v| v.nil? }
      def relationships_for(serializer, requested_associations, include_slice)
        include_directive = JSONAPI::IncludeDirective.new(
          requested_associations,
          allow_wildcard: true
        )
        serializer.associations(include_directive, include_slice).each_with_object({}) do |association, hash|
          hash[association.key] = Relationship.new(serializer, instance_options, association).as_json
        end
      end

      # {http://jsonapi.org/format/#document-links Document Links}
      # links
      # definition:
      #  JSON Object
      #
      # properties:
      #   self    : URI
      #   related : link
      #
      # description:
      #   A resource object **MAY** contain references to other resource objects ("relationships").
      #   Relationships may be to-one or to-many. Relationships can be specified by including a member
      #   in a resource's links object.
      #
      #   A `self` member’s value is a URL for the relationship itself (a "relationship URL"). This
      #   URL allows the client to directly manipulate the relationship. For example, it would allow
      #   a client to remove an `author` from an `article` without deleting the people resource
      #   itself.
      # structure:
      #   {
      #     self: 'http://example.com/etc',
      #     related: link
      #   }.reject! {|_,v| v.nil? }
      def links_for(serializer)
        serializer._links.each_with_object({}) do |(name, value), hash|
          result = Link.new(serializer, value).as_json
          hash[name] = result if result
        end
      end

      # {http://jsonapi.org/format/#fetching-pagination Pagination Links}
      # pagination
      # definition:
      #   first : pageObject
      #   last  : pageObject
      #   prev  : pageObject
      #   next  : pageObject
      # structure:
      #   {
      #     first: pageObject,
      #     last: pageObject,
      #     prev: pageObject,
      #     next: pageObject
      #   }
      #
      # pageObject
      # definition:
      #   oneOf
      #     URI
      #     null
      #
      # description:
      #   The <x> page of data
      # structure:
      #   if has_page?
      #     'http://example.com/some-page?page[number][x]'
      #   else
      #     nil
      #   end
      # prs:
      #   https://github.com/rails-api/active_model_serializers/pull/1041
      def pagination_links_for(serializer)
        PaginationLinks.new(serializer.object, instance_options).as_json
      end

      # {http://jsonapi.org/format/#document-meta Docment Meta}
      def meta_for(serializer)
        Meta.new(serializer).as_json
      end
    end
  end
end
# rubocop:enable Style/AsciiComments
