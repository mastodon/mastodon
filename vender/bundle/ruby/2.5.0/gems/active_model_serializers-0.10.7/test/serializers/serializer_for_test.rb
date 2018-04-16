require 'test_helper'

module ActiveModel
  class Serializer
    class SerializerForTest < ActiveSupport::TestCase
      class CollectionSerializerTest < ActiveSupport::TestCase
        def setup
          @array = [1, 2, 3]
          @previous_collection_serializer = ActiveModelSerializers.config.collection_serializer
        end

        def teardown
          ActiveModelSerializers.config.collection_serializer = @previous_collection_serializer
        end

        def test_serializer_for_array
          serializer = ActiveModel::Serializer.serializer_for(@array)
          assert_equal ActiveModelSerializers.config.collection_serializer, serializer
        end

        def test_overwritten_serializer_for_array
          new_collection_serializer = Class.new
          ActiveModelSerializers.config.collection_serializer = new_collection_serializer
          serializer = ActiveModel::Serializer.serializer_for(@array)
          assert_equal new_collection_serializer, serializer
        end
      end

      class SerializerTest < ActiveSupport::TestCase
        module ResourceNamespace
          class Post    < ::Model; end
          class Comment < ::Model; end

          class PostSerializer < ActiveModel::Serializer
            class CommentSerializer < ActiveModel::Serializer
            end
          end
        end

        class MyProfile < Profile
        end

        class CustomProfile
          def serializer_class
            ProfileSerializer
          end
        end

        class Tweet < ::Model; end
        TweetSerializer = Class.new

        def setup
          @profile = Profile.new
          @my_profile = MyProfile.new
          @custom_profile = CustomProfile.new
          @model = ::Model.new
          @tweet = Tweet.new
        end

        def test_serializer_for_non_ams_serializer
          serializer = ActiveModel::Serializer.serializer_for(@tweet)
          assert_nil serializer
        end

        def test_serializer_for_existing_serializer
          serializer = ActiveModel::Serializer.serializer_for(@profile)
          assert_equal ProfileSerializer, serializer
        end

        def test_serializer_for_existing_serializer_with_lookup_disabled
          serializer = with_serializer_lookup_disabled do
            ActiveModel::Serializer.serializer_for(@profile)
          end
          assert_nil serializer
        end

        def test_serializer_for_not_existing_serializer
          serializer = ActiveModel::Serializer.serializer_for(@model)
          assert_nil serializer
        end

        def test_serializer_inherited_serializer
          serializer = ActiveModel::Serializer.serializer_for(@my_profile)
          assert_equal ProfileSerializer, serializer
        end

        def test_serializer_inherited_serializer_with_lookup_disabled
          serializer = with_serializer_lookup_disabled do
            ActiveModel::Serializer.serializer_for(@my_profile)
          end
          assert_nil serializer
        end

        def test_serializer_custom_serializer
          serializer = ActiveModel::Serializer.serializer_for(@custom_profile)
          assert_equal ProfileSerializer, serializer
        end

        def test_serializer_custom_serializer_with_lookup_disabled
          serializer = with_serializer_lookup_disabled do
            ActiveModel::Serializer.serializer_for(@custom_profile)
          end
          assert_equal ProfileSerializer, serializer
        end

        def test_serializer_for_namespaced_resource
          post = ResourceNamespace::Post.new
          serializer = ActiveModel::Serializer.serializer_for(post)
          assert_equal ResourceNamespace::PostSerializer, serializer
        end

        def test_serializer_for_namespaced_resource_with_lookup_disabled
          post = ResourceNamespace::Post.new
          serializer = with_serializer_lookup_disabled do
            ActiveModel::Serializer.serializer_for(post)
          end
          assert_nil serializer
        end

        def test_serializer_for_nested_resource
          comment = ResourceNamespace::Comment.new
          serializer = ResourceNamespace::PostSerializer.serializer_for(comment)
          assert_equal ResourceNamespace::PostSerializer::CommentSerializer, serializer
        end

        def test_serializer_for_nested_resource_with_lookup_disabled
          comment = ResourceNamespace::Comment.new
          serializer = with_serializer_lookup_disabled do
            ResourceNamespace::PostSerializer.serializer_for(comment)
          end
          assert_nil serializer
        end
      end
    end
  end
end
