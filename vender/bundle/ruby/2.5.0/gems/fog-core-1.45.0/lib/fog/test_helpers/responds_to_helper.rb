module Shindo
  class Tests
    def responds_to(method_names)
      method_names.each do |method_name|
        tests("#respond_to?(:#{method_name})").returns(true) do
          @instance.respond_to?(method_name)
        end
      end
    end
  end
end
