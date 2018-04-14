module Aws
  # @api private
  class TypeBuilder

    def initialize(svc_module)
      @types_module = svc_module.const_set(:Types, Module.new)
    end

    def build_type(shape, shapes)
      @types_module.const_set(shape.name, Structure.new(*shape.member_names))
    end

  end
end
