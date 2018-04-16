module ActiveModelSerializers
  module JsonPointer
    module_function

    POINTERS = {
      attribute:    '/data/attributes/%s'.freeze,
      primary_data: '/data%s'.freeze
    }.freeze

    def new(pointer_type, value = nil)
      format(POINTERS[pointer_type], value)
    end
  end
end
