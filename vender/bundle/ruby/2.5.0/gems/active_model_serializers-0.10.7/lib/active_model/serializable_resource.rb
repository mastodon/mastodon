require 'set'

module ActiveModel
  class SerializableResource
    class << self
      extend ActiveModelSerializers::Deprecate

      delegate_and_deprecate :new, ActiveModelSerializers::SerializableResource
    end
  end
end
