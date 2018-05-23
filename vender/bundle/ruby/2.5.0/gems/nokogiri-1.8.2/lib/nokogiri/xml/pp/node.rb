module Nokogiri
  module XML
    module PP
      module Node
        def inspect # :nodoc:
          attributes = inspect_attributes.reject { |x|
            begin
              attribute = send x
              !attribute || (attribute.respond_to?(:empty?) && attribute.empty?)
            rescue NoMethodError
              true
            end
          }.map { |attribute|
            "#{attribute.to_s.sub(/_\w+/, 's')}=#{send(attribute).inspect}"
          }.join ' '
          "#<#{self.class.name}:#{sprintf("0x%x", object_id)} #{attributes}>"
        end

        def pretty_print pp # :nodoc:
          nice_name = self.class.name.split('::').last
          pp.group(2, "#(#{nice_name}:#{sprintf("0x%x", object_id)} {", '})') do

            pp.breakable
            attrs = inspect_attributes.map { |t|
              [t, send(t)] if respond_to?(t)
            }.compact.find_all { |x|
              if x.last
                if [:attribute_nodes, :children].include? x.first
                  !x.last.empty?
                else
                  true
                end
              end
            }

            pp.seplist(attrs) do |v|
              if [:attribute_nodes, :children].include? v.first
                pp.group(2, "#{v.first.to_s.sub(/_\w+$/, 's')} = [", "]") do
                  pp.breakable
                  pp.seplist(v.last) do |item|
                    pp.pp item
                  end
                end
              else
                pp.text "#{v.first} = "
                pp.pp v.last
              end
            end
            pp.breakable

          end
        end
      end
    end
  end
end
