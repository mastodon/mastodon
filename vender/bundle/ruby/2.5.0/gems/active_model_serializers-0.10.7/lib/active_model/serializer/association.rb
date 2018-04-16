require 'active_model/serializer/lazy_association'

module ActiveModel
  class Serializer
    # This class holds all information about serializer's association.
    #
    # @api private
    Association = Struct.new(:reflection, :association_options) do
      attr_reader :lazy_association
      delegate :object, :include_data?, :virtual_value, :collection?, to: :lazy_association

      def initialize(*)
        super
        @lazy_association = LazyAssociation.new(reflection, association_options)
      end

      # @return [Symbol]
      delegate :name, to: :reflection

      # @return [Symbol]
      def key
        reflection_options.fetch(:key, name)
      end

      # @return [True,False]
      def key?
        reflection_options.key?(:key)
      end

      # @return [Hash]
      def links
        reflection_options.fetch(:links) || {}
      end

      # @return [Hash, nil]
      # This gets mutated, so cannot use the cached reflection_options
      def meta
        reflection.options[:meta]
      end

      def belongs_to?
        reflection.foreign_key_on == :self
      end

      def polymorphic?
        true == reflection_options[:polymorphic]
      end

      # @api private
      def serializable_hash(adapter_options, adapter_instance)
        association_serializer = lazy_association.serializer
        return virtual_value if virtual_value
        association_object = association_serializer && association_serializer.object
        return unless association_object

        serialization = association_serializer.serializable_hash(adapter_options, {}, adapter_instance)

        if polymorphic? && serialization
          polymorphic_type = association_object.class.name.underscore
          serialization = { type: polymorphic_type, polymorphic_type.to_sym => serialization }
        end

        serialization
      end

      private

      delegate :reflection_options, to: :lazy_association
    end
  end
end
