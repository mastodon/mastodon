# frozen_string_literal: true
module Hamlit
  class Identity
    def initialize
      @unique_id = 0
    end

    def generate
      @unique_id += 1
      "_hamlit_compiler#{@unique_id}"
    end
  end
end
