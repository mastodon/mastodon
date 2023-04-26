# frozen_string_literal: true

module CacheConcern
  extend ActiveSupport::Concern

  module ActiveRecordCoder
    EMPTY_HASH = {}.freeze

    class << self
      def dump(record)
        instances = InstanceTracker.new
        serialized_associations = serialize_associations(record, instances)
        serialized_records = instances.map { |r| serialize_record(r) }
        [serialized_associations, *serialized_records]
      end

      def load(payload)
        instances = InstanceTracker.new
        serialized_associations, *serialized_records = payload
        serialized_records.each { |attrs| instances.push(deserialize_record(*attrs)) }
        deserialize_associations(serialized_associations, instances)
      end

      private

      # Records without associations, or which have already been visited before,
      # are serialized by their id alone.
      #
      # Records with associations are serialized as a two-element array including
      # their id and the record's association cache.
      #
      def serialize_associations(record, instances)
        return unless record

        if (id = instances.lookup(record))
          payload = id
        else
          payload = instances.push(record)

          cached_associations = record.class.reflect_on_all_associations.select do |reflection|
            record.association_cached?(reflection.name)
          end

          unless cached_associations.empty?
            serialized_associations = cached_associations.map do |reflection|
              association = record.association(reflection.name)

              serialized_target = if reflection.collection?
                                    association.target.map { |target_record| serialize_associations(target_record, instances) }
                                  else
                                    serialize_associations(association.target, instances)
                                  end

              [reflection.name, serialized_target]
            end

            payload = [payload, serialized_associations]
          end
        end

        payload
      end

      def deserialize_associations(payload, instances)
        return unless payload

        id, associations = payload
        record = instances.fetch(id)

        associations&.each do |name, serialized_target|
          begin
            association = record.association(name)
          rescue ActiveRecord::AssociationNotFoundError
            raise AssociationMissingError, "undefined association: #{name}"
          end

          target = if association.reflection.collection?
                     serialized_target.map! { |serialized_record| deserialize_associations(serialized_record, instances) }
                   else
                     deserialize_associations(serialized_target, instances)
                   end

          association.target = target
        end

        record
      end

      def serialize_record(record)
        arguments = [record.class.name, attributes_for_database(record)]
        arguments << true if record.new_record?
        arguments
      end

      if Rails.gem_version >= Gem::Version.new('7.0')
        def attributes_for_database(record)
          attributes = record.attributes_for_database
          attributes.transform_values! { |attr| attr.is_a?(::ActiveModel::Type::Binary::Data) ? attr.to_s : attr }
          attributes
        end
      else
        def attributes_for_database(record)
          attributes = record.instance_variable_get(:@attributes).send(:attributes).transform_values(&:value_for_database)
          attributes.transform_values! { |attr| attr.is_a?(::ActiveModel::Type::Binary::Data) ? attr.to_s : attr }
          attributes
        end
      end

      def deserialize_record(class_name, attributes_from_database, new_record = false) # rubocop:disable Style/OptionalBooleanParameter
        begin
          klass = Object.const_get(class_name)
        rescue NameError
          raise ClassMissingError, "undefined class: #{class_name}"
        end

        # Ideally we'd like to call `klass.instantiate`, however it doesn't allow to pass
        # wether the record was persisted or not.
        attributes = klass.attributes_builder.build_from_database(attributes_from_database, EMPTY_HASH)
        klass.allocate.init_with_attributes(attributes, new_record)
      end
    end

    class Error < StandardError
    end

    class ClassMissingError < Error
    end

    class AssociationMissingError < Error
    end

    class InstanceTracker
      def initialize
        @instances = []
        @ids = {}.compare_by_identity
      end

      def map(&block)
        @instances.map(&block)
      end

      def fetch(...)
        @instances.fetch(...)
      end

      def push(instance)
        id = @ids[instance] = @instances.size
        @instances << instance
        id
      end

      def lookup(instance)
        @ids[instance]
      end
    end
  end

  class_methods do
    def vary_by(value, **kwargs)
      before_action(**kwargs) do |controller|
        response.headers['Vary'] = value.respond_to?(:call) ? controller.instance_exec(&value) : value
      end
    end
  end

  included do
    after_action :enforce_cache_control!
  end

  # Prevents high-entropy headers such as `Cookie`, `Signature` or `Authorization`
  # from being used as cache keys, while allowing to `Vary` on them (to not serve
  # anonymous cached data to authenticated requests when authentication matters)
  def enforce_cache_control!
    vary = response.headers['Vary']&.split&.map { |x| x.strip.downcase }
    return unless vary.present? && %w(cookie authorization signature).any? { |header| vary.include?(header) && request.headers[header].present? }

    response.cache_control.replace(private: true, no_store: true)
  end

  def render_with_cache(**options)
    raise ArgumentError, 'Only JSON render calls are supported' unless options.key?(:json) || block_given?

    key        = options.delete(:key) || [[params[:controller], params[:action]].join('/'), options[:json].respond_to?(:cache_key) ? options[:json].cache_key : nil, options[:fields].nil? ? nil : options[:fields].join(',')].compact.join(':')
    expires_in = options.delete(:expires_in) || 3.minutes
    body       = Rails.cache.read(key, raw: true)

    if body
      render(options.except(:json, :serializer, :each_serializer, :adapter, :fields).merge(json: body))
    else
      if block_given?
        options[:json] = yield
      elsif options[:json].is_a?(Symbol)
        options[:json] = send(options[:json])
      end

      render(options)
      Rails.cache.write(key, response.body, expires_in: expires_in, raw: true)
    end
  end

  def cache_collection(raw, klass)
    return raw unless klass.respond_to?(:with_includes)

    raw = raw.cache_ids.to_a if raw.is_a?(ActiveRecord::Relation)
    return [] if raw.empty?

    cached_keys_with_value = begin
      Rails.cache.read_multi(*raw).transform_keys(&:id).transform_values { |r| ActiveRecordCoder.load(r) }
    rescue ActiveRecordCoder::Error
      {} # The serialization format may have changed, let's pretend it's a cache miss.
    end

    uncached_ids = raw.map(&:id) - cached_keys_with_value.keys

    klass.reload_stale_associations!(cached_keys_with_value.values) if klass.respond_to?(:reload_stale_associations!)

    unless uncached_ids.empty?
      uncached = klass.where(id: uncached_ids).with_includes.index_by(&:id)

      uncached.each_value do |item|
        Rails.cache.write(item, ActiveRecordCoder.dump(item))
      end
    end

    raw.filter_map { |item| cached_keys_with_value[item.id] || uncached[item.id] }
  end

  def cache_collection_paginated_by_id(raw, klass, limit, options)
    cache_collection raw.cache_ids.to_a_paginated_by_id(limit, options), klass
  end
end
