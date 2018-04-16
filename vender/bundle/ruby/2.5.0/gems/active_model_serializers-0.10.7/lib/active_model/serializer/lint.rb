module ActiveModel
  class Serializer
    module Lint
      # == Active \Model \Serializer \Lint \Tests
      #
      # You can test whether an object is compliant with the Active \Model \Serializers
      # API by including <tt>ActiveModel::Serializer::Lint::Tests</tt> in your TestCase.
      # It will include tests that tell you whether your object is fully compliant,
      # or if not, which aspects of the API are not implemented.
      #
      # Note an object is not required to implement all APIs in order to work
      # with Active \Model \Serializers. This module only intends to provide guidance in case
      # you want all features out of the box.
      #
      # These tests do not attempt to determine the semantic correctness of the
      # returned values. For instance, you could implement <tt>serializable_hash</tt> to
      # always return +{}+, and the tests would pass. It is up to you to ensure
      # that the values are semantically meaningful.
      module Tests
        # Passes if the object responds to <tt>serializable_hash</tt> and if it takes
        # zero or one arguments.
        # Fails otherwise.
        #
        # <tt>serializable_hash</tt> returns a hash representation of a object's attributes.
        # Typically, it is implemented by including ActiveModel::Serialization.
        def test_serializable_hash
          assert_respond_to resource, :serializable_hash, 'The resource should respond to serializable_hash'
          resource.serializable_hash
          resource.serializable_hash(nil)
        end

        # Passes if the object responds to <tt>read_attribute_for_serialization</tt>
        # and if it requires one argument (the attribute to be read).
        # Fails otherwise.
        #
        # <tt>read_attribute_for_serialization</tt> gets the attribute value for serialization
        # Typically, it is implemented by including ActiveModel::Serialization.
        def test_read_attribute_for_serialization
          assert_respond_to resource, :read_attribute_for_serialization, 'The resource should respond to read_attribute_for_serialization'
          actual_arity = resource.method(:read_attribute_for_serialization).arity
          # using absolute value since arity is:
          #  1 for def read_attribute_for_serialization(name); end
          # -1 for alias :read_attribute_for_serialization :send
          assert_equal 1, actual_arity.abs, "expected #{actual_arity.inspect}.abs to be 1 or -1"
        end

        # Passes if the object responds to <tt>as_json</tt> and if it takes
        # zero or one arguments.
        # Fails otherwise.
        #
        # <tt>as_json</tt> returns a hash representation of a serialized object.
        # It may delegate to <tt>serializable_hash</tt>
        # Typically, it is implemented either by including ActiveModel::Serialization
        # which includes ActiveModel::Serializers::JSON.
        # or by the JSON gem when required.
        def test_as_json
          assert_respond_to resource, :as_json
          resource.as_json
          resource.as_json(nil)
        end

        # Passes if the object responds to <tt>to_json</tt> and if it takes
        # zero or one arguments.
        # Fails otherwise.
        #
        # <tt>to_json</tt> returns a string representation (JSON) of a serialized object.
        # It may be called on the result of <tt>as_json</tt>.
        # Typically, it is implemented on all objects when the JSON gem is required.
        def test_to_json
          assert_respond_to resource, :to_json
          resource.to_json
          resource.to_json(nil)
        end

        # Passes if the object responds to <tt>cache_key</tt>
        # Fails otherwise.
        #
        # <tt>cache_key</tt> returns a (self-expiring) unique key for the object,
        # and is part of the (self-expiring) cache_key, which is used by the
        # adapter. It is not required unless caching is enabled.
        def test_cache_key
          assert_respond_to resource, :cache_key
          actual_arity = resource.method(:cache_key).arity
          assert_includes [-1, 0], actual_arity, "expected #{actual_arity.inspect} to be 0 or -1"
        end

        # Passes if the object responds to <tt>updated_at</tt> and if it takes no
        # arguments.
        # Fails otherwise.
        #
        # <tt>updated_at</tt> returns a Time object or iso8601 string and
        # is part of the (self-expiring) cache_key, which is used by the adapter.
        # It is not required unless caching is enabled.
        def test_updated_at
          assert_respond_to resource, :updated_at
          actual_arity = resource.method(:updated_at).arity
          assert_equal 0, actual_arity
        end

        # Passes if the object responds to <tt>id</tt> and if it takes no
        # arguments.
        # Fails otherwise.
        #
        # <tt>id</tt> returns a unique identifier for the object.
        # It is not required unless caching is enabled.
        def test_id
          assert_respond_to resource, :id
          assert_equal 0, resource.method(:id).arity
        end

        # Passes if the object's class responds to <tt>model_name</tt> and if it
        # is in an instance of +ActiveModel::Name+.
        # Fails otherwise.
        #
        # <tt>model_name</tt> returns an ActiveModel::Name instance.
        # It is used by the serializer to identify the object's type.
        # It is not required unless caching is enabled.
        def test_model_name
          resource_class = resource.class
          assert_respond_to resource_class, :model_name
          assert_instance_of resource_class.model_name, ActiveModel::Name
        end

        def test_active_model_errors
          assert_respond_to resource, :errors
        end

        def test_active_model_errors_human_attribute_name
          assert_respond_to resource.class, :human_attribute_name
          assert_equal(-2, resource.class.method(:human_attribute_name).arity)
        end

        def test_active_model_errors_lookup_ancestors
          assert_respond_to resource.class, :lookup_ancestors
          assert_equal 0, resource.class.method(:lookup_ancestors).arity
        end

        private

        def resource
          @resource or fail "'@resource' must be set as the linted object"
        end

        def assert_instance_of(result, name)
          assert result.instance_of?(name), "#{result} should be an instance of #{name}"
        end
      end
    end
  end
end
