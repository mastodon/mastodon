require 'test_helper'
module ActiveModel
  class Serializer
    class ReflectionTest < ActiveSupport::TestCase
      class Blog < ActiveModelSerializers::Model
        attributes :id
      end
      class BlogSerializer < ActiveModel::Serializer
        type 'blog'
        attributes :id
      end

      setup do
        @expected_meta = { id: 1 }
        @expected_links = { self: 'no_uri_validation' }
        @empty_links = {}
        model_attributes = { blog: Blog.new(@expected_meta) }
        @model = Class.new(ActiveModelSerializers::Model) do
          attributes(*model_attributes.keys)

          def self.name
            'TestModel'
          end
        end.new(model_attributes)
        @instance_options = {}
      end

      def evaluate_association_value(association)
        association.lazy_association.eval_reflection_block
      end

      # TODO: Remaining tests
      # test_reflection_value_block_with_scope
      # test_reflection_value_uses_serializer_instance_method
      # test_reflection_excluded_eh_blank_is_false
      # test_reflection_excluded_eh_if
      # test_reflection_excluded_eh_unless
      # test_evaluate_condition_symbol_serializer_method
      # test_evaluate_condition_string_serializer_method
      # test_evaluate_condition_proc
      # test_evaluate_condition_proc_yields_serializer
      # test_evaluate_condition_other
      # test_options_key
      # test_options_polymorphic
      # test_options_serializer
      # test_options_virtual_value
      # test_options_namespace

      def test_reflection_value
        serializer_class = Class.new(ActiveModel::Serializer) do
          has_one :blog
        end
        serializer_instance = serializer_class.new(@model, @instance_options)

        # Get Reflection
        reflection = serializer_class._reflections.fetch(:blog)

        # Assert
        assert_nil reflection.block
        assert_equal Serializer.config.include_data_default, reflection.options.fetch(:include_data_setting)
        assert_equal true, reflection.options.fetch(:include_data_setting)

        include_slice = :does_not_matter
        assert_equal @model.blog, reflection.send(:value, serializer_instance, include_slice)
      end

      def test_reflection_value_block
        serializer_class = Class.new(ActiveModel::Serializer) do
          has_one :blog do
            object.blog
          end
        end
        serializer_instance = serializer_class.new(@model, @instance_options)

        # Get Reflection
        reflection = serializer_class._reflections.fetch(:blog)

        # Assert
        assert_respond_to reflection.block, :call
        assert_equal Serializer.config.include_data_default, reflection.options.fetch(:include_data_setting)
        assert_equal true, reflection.options.fetch(:include_data_setting)

        include_slice = :does_not_matter
        assert_equal @model.blog, reflection.send(:value, serializer_instance, include_slice)
      end

      def test_reflection_value_block_with_explicit_include_data_true
        serializer_class = Class.new(ActiveModel::Serializer) do
          has_one :blog do
            include_data true
            object.blog
          end
        end
        serializer_instance = serializer_class.new(@model, @instance_options)

        # Get Reflection
        reflection = serializer_class._reflections.fetch(:blog)

        # Assert
        assert_respond_to reflection.block, :call
        assert_equal Serializer.config.include_data_default, reflection.options.fetch(:include_data_setting)
        assert_equal true, reflection.options.fetch(:include_data_setting)

        include_slice = :does_not_matter
        assert_equal @model.blog, reflection.send(:value, serializer_instance, include_slice)
      end

      def test_reflection_value_block_with_include_data_false_mutates_the_reflection_include_data
        serializer_class = Class.new(ActiveModel::Serializer) do
          has_one :blog do
            include_data false
            object.blog
          end
        end
        serializer_instance = serializer_class.new(@model, @instance_options)

        # Get Reflection
        reflection = serializer_class._reflections.fetch(:blog)

        # Assert
        assert_respond_to reflection.block, :call
        assert_equal true, reflection.options.fetch(:include_data_setting)
        include_slice = :does_not_matter
        assert_nil reflection.send(:value, serializer_instance, include_slice)
        assert_equal false, reflection.options.fetch(:include_data_setting)
      end

      def test_reflection_value_block_with_include_data_if_sideloaded_included_mutates_the_reflection_include_data
        serializer_class = Class.new(ActiveModel::Serializer) do
          has_one :blog do
            include_data :if_sideloaded
            object.blog
          end
        end
        serializer_instance = serializer_class.new(@model, @instance_options)

        # Get Reflection
        reflection = serializer_class._reflections.fetch(:blog)

        # Assert
        assert_respond_to reflection.block, :call
        assert_equal true, reflection.options.fetch(:include_data_setting)
        include_slice = {}
        assert_nil reflection.send(:value, serializer_instance, include_slice)
        assert_equal :if_sideloaded, reflection.options.fetch(:include_data_setting)
      end

      def test_reflection_value_block_with_include_data_if_sideloaded_excluded_mutates_the_reflection_include_data
        serializer_class = Class.new(ActiveModel::Serializer) do
          has_one :blog do
            include_data :if_sideloaded
            object.blog
          end
        end
        serializer_instance = serializer_class.new(@model, @instance_options)

        # Get Reflection
        reflection = serializer_class._reflections.fetch(:blog)

        # Assert
        assert_respond_to reflection.block, :call
        assert_equal true, reflection.options.fetch(:include_data_setting)
        include_slice = { blog: :does_not_matter }
        assert_equal @model.blog, reflection.send(:value, serializer_instance, include_slice)
        assert_equal :if_sideloaded, reflection.options.fetch(:include_data_setting)
      end

      def test_reflection_block_with_link_mutates_the_reflection_links
        serializer_class = Class.new(ActiveModel::Serializer) do
          has_one :blog do
            link :self, 'no_uri_validation'
          end
        end
        serializer_instance = serializer_class.new(@model, @instance_options)

        # Get Reflection
        reflection = serializer_class._reflections.fetch(:blog)
        assert_equal @empty_links, reflection.options.fetch(:links)

        # Build Association
        association = reflection.build_association(serializer_instance, @instance_options)

        # Assert association links empty when not yet evaluated
        assert_equal @empty_links, reflection.options.fetch(:links)
        assert_equal @empty_links, association.links

        evaluate_association_value(association)

        assert_equal @expected_links, association.links
        assert_equal @expected_links, reflection.options.fetch(:links)
      end

      def test_reflection_block_with_link_block_mutates_the_reflection_links
        serializer_class = Class.new(ActiveModel::Serializer) do
          has_one :blog do
            link :self do
              'no_uri_validation'
            end
          end
        end
        serializer_instance = serializer_class.new(@model, @instance_options)

        # Get Reflection
        reflection = serializer_class._reflections.fetch(:blog)
        assert_equal @empty_links, reflection.options.fetch(:links)

        # Build Association
        association = reflection.build_association(serializer_instance, @instance_options)

        # Assert association links empty when not yet evaluated
        assert_equal @empty_links, association.links

        evaluate_association_value(association)

        # Assert before instance_eval link
        link = association.links.fetch(:self)
        assert_respond_to link, :call
        assert_respond_to reflection.options.fetch(:links).fetch(:self), :call

        # Assert after instance_eval link
        assert_equal @expected_links.fetch(:self), reflection.instance_eval(&link)
        assert_respond_to reflection.options.fetch(:links).fetch(:self), :call
      end

      def test_reflection_block_with_meta_mutates_the_reflection_meta
        serializer_class = Class.new(ActiveModel::Serializer) do
          has_one :blog do
            meta(id: object.blog.id)
          end
        end
        serializer_instance = serializer_class.new(@model, @instance_options)

        # Get Reflection
        reflection = serializer_class._reflections.fetch(:blog)
        assert_nil reflection.options.fetch(:meta)

        # Build Association
        association = reflection.build_association(serializer_instance, @instance_options)

        evaluate_association_value(association)

        assert_equal @expected_meta, association.meta
        assert_equal @expected_meta, reflection.options.fetch(:meta)
      end

      def test_reflection_block_with_meta_block_mutates_the_reflection_meta
        serializer_class = Class.new(ActiveModel::Serializer) do
          has_one :blog do
            meta do
              { id: object.blog.id }
            end
          end
        end
        serializer_instance = serializer_class.new(@model, @instance_options)

        # Get Reflection
        reflection = serializer_class._reflections.fetch(:blog)
        assert_nil reflection.options.fetch(:meta)

        # Build Association
        association = reflection.build_association(serializer_instance, @instance_options)
        # Assert before instance_eval meta

        evaluate_association_value(association)

        assert_respond_to association.meta, :call
        assert_respond_to reflection.options.fetch(:meta), :call

        # Assert after instance_eval meta
        assert_equal @expected_meta, reflection.instance_eval(&association.meta)
        assert_respond_to reflection.options.fetch(:meta), :call
        assert_respond_to association.meta, :call
      end

      # rubocop:disable Metrics/AbcSize
      def test_reflection_block_with_meta_in_link_block_mutates_the_reflection_meta
        serializer_class = Class.new(ActiveModel::Serializer) do
          has_one :blog do
            link :self do
              meta(id: object.blog.id)
              'no_uri_validation'
            end
          end
        end
        serializer_instance = serializer_class.new(@model, @instance_options)

        # Get Reflection
        reflection = serializer_class._reflections.fetch(:blog)
        assert_nil reflection.options.fetch(:meta)
        assert_equal @empty_links, reflection.options.fetch(:links)

        # Build Association
        association = reflection.build_association(serializer_instance, @instance_options)
        # Assert before instance_eval link meta
        assert_nil association.meta
        assert_nil reflection.options.fetch(:meta)

        evaluate_association_value(association)

        link = association.links.fetch(:self)
        assert_respond_to link, :call
        assert_respond_to reflection.options.fetch(:links).fetch(:self), :call
        assert_nil reflection.options.fetch(:meta)

        # Assert after instance_eval link
        assert_equal 'no_uri_validation', reflection.instance_eval(&link)
        assert_equal @expected_meta, reflection.options.fetch(:meta)
        assert_equal @expected_meta, association.meta
      end
      # rubocop:enable Metrics/AbcSize

      # rubocop:disable Metrics/AbcSize
      def test_reflection_block_with_meta_block_in_link_block_mutates_the_reflection_meta
        serializer_class = Class.new(ActiveModel::Serializer) do
          has_one :blog do
            link :self do
              meta do
                { id: object.blog.id }
              end
              'no_uri_validation'
            end
          end
        end
        serializer_instance = serializer_class.new(@model, @instance_options)

        # Get Reflection
        reflection = serializer_class._reflections.fetch(:blog)
        assert_nil reflection.options.fetch(:meta)

        # Build Association
        association = reflection.build_association(serializer_instance, @instance_options)
        assert_nil association.meta
        assert_nil reflection.options.fetch(:meta)

        # Assert before instance_eval link

        evaluate_association_value(association)

        link = association.links.fetch(:self)
        assert_nil reflection.options.fetch(:meta)
        assert_respond_to link, :call
        assert_respond_to association.links.fetch(:self), :call

        # Assert after instance_eval link
        assert_equal 'no_uri_validation', reflection.instance_eval(&link)
        assert_respond_to association.links.fetch(:self), :call
        # Assert before instance_eval link meta
        assert_respond_to reflection.options.fetch(:meta), :call
        assert_respond_to association.meta, :call

        # Assert after instance_eval link meta
        assert_equal @expected_meta, reflection.instance_eval(&reflection.options.fetch(:meta))
        assert_respond_to association.meta, :call
      end
      # rubocop:enable Metrics/AbcSize

      def test_no_href_in_vanilla_reflection
        serializer_class = Class.new(ActiveModel::Serializer) do
          has_one :blog do
            link :self do
              href 'no_uri_validation'
            end
          end
        end
        serializer_instance = serializer_class.new(@model, @instance_options)

        # Get Reflection
        reflection = serializer_class._reflections.fetch(:blog)
        assert_equal @empty_links, reflection.options.fetch(:links)

        # Build Association
        association = reflection.build_association(serializer_instance, @instance_options)
        # Assert before instance_eval link

        evaluate_association_value(association)

        link = association.links.fetch(:self)
        assert_respond_to link, :call

        # Assert after instance_eval link
        exception = assert_raise(NoMethodError) do
          reflection.instance_eval(&link)
        end
        assert_match(/undefined method `href'/, exception.message)
      end

      # rubocop:disable Metrics/AbcSize
      def test_mutating_reflection_block_is_not_thread_safe
        serializer_class = Class.new(ActiveModel::Serializer) do
          has_one :blog do
            meta(id: object.blog.id)
          end
        end
        model1_meta = @expected_meta
        # Evaluate reflection meta for model with id 1
        serializer_instance = serializer_class.new(@model, @instance_options)
        reflection = serializer_class._reflections.fetch(:blog)
        assert_nil reflection.options.fetch(:meta)
        association = reflection.build_association(serializer_instance, @instance_options)

        evaluate_association_value(association)

        assert_equal model1_meta, association.meta
        assert_equal model1_meta, reflection.options.fetch(:meta)

        model2_meta = @expected_meta.merge(id: 2)
        # Evaluate reflection meta for model with id 2
        @model.blog.id = 2
        assert_equal 2, @model.blog.id # sanity check
        serializer_instance = serializer_class.new(@model, @instance_options)
        reflection = serializer_class._reflections.fetch(:blog)

        # WARN: Thread-safety issue
        # Before the reflection is evaluated, it has the value from the previous evaluation
        assert_equal model1_meta, reflection.options.fetch(:meta)

        association = reflection.build_association(serializer_instance, @instance_options)

        evaluate_association_value(association)

        assert_equal model2_meta, association.meta
        assert_equal model2_meta, reflection.options.fetch(:meta)
      end
      # rubocop:enable Metrics/AbcSize
    end
  end
end
