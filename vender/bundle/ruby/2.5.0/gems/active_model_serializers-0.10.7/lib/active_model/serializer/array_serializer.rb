require 'active_model/serializer/collection_serializer'

module ActiveModel
  class Serializer
    class ArraySerializer < CollectionSerializer
      class << self
        extend ActiveModelSerializers::Deprecate
        deprecate :new, 'ActiveModel::Serializer::CollectionSerializer.'
      end
    end
  end
end
