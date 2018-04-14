require 'test_helper'

module ActiveModel
  class Serializer
    module Adapter
      class PolymorphicTest < ActiveSupport::TestCase
        setup do
          @employee = Employee.new(id: 42, name: 'Zoop Zoopler', email: 'zoop@example.com')
          @picture = @employee.pictures.new(id: 1, title: 'headshot-1.jpg')
          @picture.imageable = @employee
        end

        def serialization(resource, adapter = :attributes)
          serializable(resource, adapter: adapter, serializer: PolymorphicBelongsToSerializer).as_json
        end

        def tag_serialization(adapter = :attributes)
          tag = PolyTag.new(id: 1, phrase: 'foo')
          tag.object_tags << ObjectTag.new(id: 1, poly_tag_id: 1, taggable: @employee)
          tag.object_tags << ObjectTag.new(id: 5, poly_tag_id: 1, taggable: @picture)
          serializable(tag, adapter: adapter, serializer: PolymorphicTagSerializer, include: '*.*').as_json
        end

        def test_attributes_serialization
          expected =
            {
              id: 1,
              title: 'headshot-1.jpg',
              imageable: {
                type: 'employee',
                employee: {
                  id: 42,
                  name: 'Zoop Zoopler'
                }
              }
            }

          assert_equal(expected, serialization(@picture))
        end

        def test_attributes_serialization_without_polymorphic_association
          expected =
            {
              id: 2,
              title: 'headshot-2.jpg',
              imageable: nil
            }

          simple_picture = Picture.new(id: 2, title: 'headshot-2.jpg')
          assert_equal(expected, serialization(simple_picture))
        end

        def test_attributes_serialization_with_polymorphic_has_many
          expected =
            {
              id: 1,
              phrase: 'foo',
              object_tags: [
                {
                  id: 1,
                  taggable: {
                    type: 'employee',
                    employee: {
                      id: 42
                    }
                  }
                },
                {
                  id: 5,
                  taggable: {
                    type: 'picture',
                    picture: {
                      id: 1
                    }
                  }
                }
              ]
            }
          assert_equal(expected, tag_serialization)
        end

        def test_json_serialization
          expected =
            {
              picture: {
                id: 1,
                title: 'headshot-1.jpg',
                imageable: {
                  type: 'employee',
                  employee: {
                    id: 42,
                    name: 'Zoop Zoopler'
                  }
                }
              }
            }

          assert_equal(expected, serialization(@picture, :json))
        end

        def test_json_serialization_without_polymorphic_association
          expected =
            {
              picture: {
                id: 2,
                title: 'headshot-2.jpg',
                imageable: nil
              }
            }

          simple_picture = Picture.new(id: 2, title: 'headshot-2.jpg')
          assert_equal(expected, serialization(simple_picture, :json))
        end

        def test_json_serialization_with_polymorphic_has_many
          expected =
            {
              poly_tag: {
                id: 1,
                phrase: 'foo',
                object_tags: [
                  {
                    id: 1,
                    taggable: {
                      type: 'employee',
                      employee: {
                        id: 42
                      }
                    }
                  },
                  {
                    id: 5,
                    taggable: {
                      type: 'picture',
                      picture: {
                        id: 1
                      }
                    }
                  }
                ]
              }
            }
          assert_equal(expected, tag_serialization(:json))
        end

        def test_json_api_serialization
          expected =
            {
              data: {
                id: '1',
                type: 'pictures',
                attributes: {
                  title: 'headshot-1.jpg'
                },
                relationships: {
                  imageable: {
                    data: {
                      id: '42',
                      type: 'employees'
                    }
                  }
                }
              }
            }

          assert_equal(expected, serialization(@picture, :json_api))
        end

        def test_json_api_serialization_with_polymorphic_belongs_to
          expected = {
            data: {
              id: '1',
              type: 'poly-tags',
              attributes: { phrase: 'foo' },
              relationships: {
                :"object-tags" => {
                  data: [
                    { id: '1', type: 'object-tags' },
                    { id: '5', type: 'object-tags' }
                  ]
                }
              }
            },
            included: [
              {
                id: '1',
                type: 'object-tags',
                relationships: {
                  taggable: {
                    data: { id: '42', type: 'employees' }
                  }
                }
              },
              {
                id: '42',
                type: 'employees'
              },
              {
                id: '5',
                type: 'object-tags',
                relationships: {
                  taggable: {
                    data: { id: '1', type: 'pictures' }
                  }
                }
              },
              {
                id: '1',
                type: 'pictures'
              }
            ]
          }
          assert_equal(expected, tag_serialization(:json_api))
        end
      end
    end
  end
end
