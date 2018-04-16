module Chewy
  class Type
    module Adapter
      # Basic adapter class. Contains interface, need to implement to add any classes support
      class Base
        BATCH_SIZE = 1000

        attr_reader :target, :options

        # Returns `true` if this adapter is applicable for the given target.
        #
        def self.accepts?(_target)
          true
        end

        # Camelcased name, used as type class constant name.
        # For returned value 'Product' will be generated class name `ProductsIndex::Product`
        #
        def name
          raise NotImplementedError
        end

        # Underscored type name, user for elasticsearch type creation
        # and for type class access with ProductsIndex.type_hash hash or method.
        # `ProductsIndex.type_hash['product']` or `ProductsIndex.product`
        #
        def type_name
          @type_name ||= name.underscore
        end

        # Returns shortest identifies for further postponed importing.
        # For ORM/ODM it will be an array of ids for simple objects -
        # just objects themselves
        #
        def identify(_collection)
          raise NotImplementedError
        end

        # Splits passed objects to groups according to `:batch_size` options.
        # For every group creates hash with action keys. Example:
        #
        #   { delete: [object_or_id1, object_or_id2], index: [object3, object4, object5] }
        #
        # @yieldparam _batch [Array<Object>] each batch of objects
        # @return [true, false] returns true if all the block call returns true and false otherwise
        def import(_batch, &_block)
          raise NotImplementedError
        end

        # Unlike {#import} fetches only ids (references) to the imported objects,
        # using the same procedures as {#import}.
        #
        # @param _fields [Array<Symbol>] additional fields to fetch
        # @param _batch_size [Integer] batch size, defaults to 1000
        # @yieldparam batch [Array<Object>] each batch of objects
        def import_fields(_fields, _batch_size, &_block)
          raise NotImplementedError
        end

        # Uses the same strategy as import for the passed arguments, and returns
        # an array of references to the passed objects. Returns ids if possible.
        # Otherwise - and array of objects themselves.
        #
        # @param _batch_size [Integer] batch size, defaults to 1000
        # @yieldparam batch [Array<Object>] each batch of objects
        def import_references(_batch_size, &_block)
          raise NotImplementedError
        end

        # Returns array of loaded objects for passed ids array. If some object
        # was not loaded, it returns `nil` in the place of this object
        #
        #   load([1, 2, 3]) #=>
        #     # [<Product id: 1>, nil, <Product id: 3>], assuming, #2 was not found
        #
        def load(_ids, **_options)
          raise NotImplementedError
        end

      private

        def grouped_objects(objects)
          objects.to_a.group_by do |object|
            delete_from_index?(object) ? :delete : :index
          end
        end

        def delete_from_index?(object)
          delete_if = options[:delete_if]
          delete ||= case delete_if
          when Symbol, String
            object.send delete_if
          when Proc
            delete_if.arity == 1 ? delete_if.call(object) : object.instance_exec(&delete_if)
          end

          !!delete
        end
      end
    end
  end
end
