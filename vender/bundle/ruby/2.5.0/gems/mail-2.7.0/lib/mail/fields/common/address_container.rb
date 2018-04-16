# frozen_string_literal: true
module Mail
  
  class AddressContainer < Array
    
    def initialize(field, list = [])
      @field = field
      super(list)
    end

    def <<(address)
      @field << address
    end

  end
  
end
