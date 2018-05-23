module ActiveModelSerializers
  module Adapter
    class JsonApi
      # NOTE(Experimental):
      # This is an experimental feature. Both the interface and internals could be subject
      # to changes.
      module Deserialization
        InvalidDocument = Class.new(ArgumentError)

        module_function

        # Transform a JSON API document, containing a single data object,
        # into a hash that is ready for ActiveRecord::Base.new() and such.
        # Raises InvalidDocument if the payload is not properly formatted.
        #
        # @param [Hash|ActionController::Parameters] document
        # @param [Hash] options
        #   only: Array of symbols of whitelisted fields.
        #   except: Array of symbols of blacklisted fields.
        #   keys: Hash of translated keys (e.g. :author => :user).
        #   polymorphic: Array of symbols of polymorphic fields.
        # @return [Hash]
        #
        # @example
        #   document = {
        #     data: {
        #       id: 1,
        #       type: 'post',
        #       attributes: {
        #         title: 'Title 1',
        #         date: '2015-12-20'
        #       },
        #       associations: {
        #         author: {
        #           data: {
        #             type: 'user',
        #             id: 2
        #           }
        #         },
        #         second_author: {
        #           data: nil
        #         },
        #         comments: {
        #           data: [{
        #             type: 'comment',
        #             id: 3
        #           },{
        #             type: 'comment',
        #             id: 4
        #           }]
        #         }
        #       }
        #     }
        #   }
        #
        #   parse(document) #=>
        #     # {
        #     #   title: 'Title 1',
        #     #   date: '2015-12-20',
        #     #   author_id: 2,
        #     #   second_author_id: nil
        #     #   comment_ids: [3, 4]
        #     # }
        #
        #   parse(document, only: [:title, :date, :author],
        #                   keys: { date: :published_at },
        #                   polymorphic: [:author]) #=>
        #     # {
        #     #   title: 'Title 1',
        #     #   published_at: '2015-12-20',
        #     #   author_id: '2',
        #     #   author_type: 'people'
        #     # }
        #
        def parse!(document, options = {})
          parse(document, options) do |invalid_payload, reason|
            fail InvalidDocument, "Invalid payload (#{reason}): #{invalid_payload}"
          end
        end

        # Same as parse!, but returns an empty hash instead of raising InvalidDocument
        # on invalid payloads.
        def parse(document, options = {})
          document = document.dup.permit!.to_h if document.is_a?(ActionController::Parameters)

          validate_payload(document) do |invalid_document, reason|
            yield invalid_document, reason if block_given?
            return {}
          end

          primary_data = document['data']
          attributes = primary_data['attributes'] || {}
          attributes['id'] = primary_data['id'] if primary_data['id']
          relationships = primary_data['relationships'] || {}

          filter_fields(attributes, options)
          filter_fields(relationships, options)

          hash = {}
          hash.merge!(parse_attributes(attributes, options))
          hash.merge!(parse_relationships(relationships, options))

          hash
        end

        # Checks whether a payload is compliant with the JSON API spec.
        #
        # @api private
        # rubocop:disable Metrics/CyclomaticComplexity
        def validate_payload(payload)
          unless payload.is_a?(Hash)
            yield payload, 'Expected hash'
            return
          end

          primary_data = payload['data']
          unless primary_data.is_a?(Hash)
            yield payload, { data: 'Expected hash' }
            return
          end

          attributes = primary_data['attributes'] || {}
          unless attributes.is_a?(Hash)
            yield payload, { data: { attributes: 'Expected hash or nil' } }
            return
          end

          relationships = primary_data['relationships'] || {}
          unless relationships.is_a?(Hash)
            yield payload, { data: { relationships: 'Expected hash or nil' } }
            return
          end

          relationships.each do |(key, value)|
            unless value.is_a?(Hash) && value.key?('data')
              yield payload, { data: { relationships: { key => 'Expected hash with :data key' } } }
            end
          end
        end
        # rubocop:enable Metrics/CyclomaticComplexity

        # @api private
        def filter_fields(fields, options)
          if (only = options[:only])
            fields.slice!(*Array(only).map(&:to_s))
          elsif (except = options[:except])
            fields.except!(*Array(except).map(&:to_s))
          end
        end

        # @api private
        def field_key(field, options)
          (options[:keys] || {}).fetch(field.to_sym, field).to_sym
        end

        # @api private
        def parse_attributes(attributes, options)
          transform_keys(attributes, options)
            .map { |(k, v)| { field_key(k, options) => v } }
            .reduce({}, :merge)
        end

        # Given an association name, and a relationship data attribute, build a hash
        # mapping the corresponding ActiveRecord attribute to the corresponding value.
        #
        # @example
        #   parse_relationship(:comments, [{ 'id' => '1', 'type' => 'comments' },
        #                                  { 'id' => '2', 'type' => 'comments' }],
        #                                 {})
        #    # => { :comment_ids => ['1', '2'] }
        #   parse_relationship(:author, { 'id' => '1', 'type' => 'users' }, {})
        #    # => { :author_id => '1' }
        #   parse_relationship(:author, nil, {})
        #    # => { :author_id => nil }
        # @param [Symbol] assoc_name
        # @param [Hash] assoc_data
        # @param [Hash] options
        # @return [Hash{Symbol, Object}]
        #
        # @api private
        def parse_relationship(assoc_name, assoc_data, options)
          prefix_key = field_key(assoc_name, options).to_s.singularize
          hash =
            if assoc_data.is_a?(Array)
              { "#{prefix_key}_ids".to_sym => assoc_data.map { |ri| ri['id'] } }
            else
              { "#{prefix_key}_id".to_sym => assoc_data ? assoc_data['id'] : nil }
            end

          polymorphic = (options[:polymorphic] || []).include?(assoc_name.to_sym)
          if polymorphic
            hash["#{prefix_key}_type".to_sym] = assoc_data.present? ? assoc_data['type'].classify : nil
          end

          hash
        end

        # @api private
        def parse_relationships(relationships, options)
          transform_keys(relationships, options)
            .map { |(k, v)| parse_relationship(k, v['data'], options) }
            .reduce({}, :merge)
        end

        # @api private
        def transform_keys(hash, options)
          transform = options[:key_transform] || :underscore
          CaseTransform.send(transform, hash)
        end
      end
    end
  end
end
