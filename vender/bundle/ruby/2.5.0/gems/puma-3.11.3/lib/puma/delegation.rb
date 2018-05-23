module Puma
  module Delegation
    def forward(what, who)
      module_eval <<-CODE
        def #{what}(*args, &block)
          #{who}.#{what}(*args, &block)
        end
      CODE
    end
  end
end
