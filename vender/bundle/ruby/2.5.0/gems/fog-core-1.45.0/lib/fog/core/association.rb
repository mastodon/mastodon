module Fog
  class Association < Collection
    def initialize(associations = [])
      @loaded = true
      load(associations)
    end

    def load(associations)
      return unless associations.kind_of?(Array)
      associations.each do |association|
        self << association
      end
    end
  end
end
