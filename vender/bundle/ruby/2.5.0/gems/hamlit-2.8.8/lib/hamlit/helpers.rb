# frozen_string_literal: true
module Hamlit
  module Helpers
    extend self

    # The same as original Haml::Helpers#preserve without block support.
    def preserve(input)
      # https://github.com/haml/haml/blob/4.1.0.beta.1/lib/haml/helpers.rb#L130-L133
      s = input.to_s.chomp("\n")
      s.gsub!(/\n/, '&#x000A;')
      s.delete!("\r")
      s
    end
  end
end
