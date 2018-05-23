module Nokogiri
  module XML
    module PP
      module CharacterData
        def pretty_print pp # :nodoc:
          nice_name = self.class.name.split('::').last
          pp.group(2, "#(#{nice_name} ", ')') do
            pp.pp text
          end
        end

        def inspect # :nodoc:
          "#<#{self.class.name}:#{sprintf("0x%x",object_id)} #{text.inspect}>"
        end
      end
    end
  end
end
