module Fog
  module Attributes
    # = Fog Time Attribute
    #
    # This class handles Time attributes from the providers,
    # converting values to Time objects
    class Time < Default
      def create_setter
        model.class_eval <<-EOS, __FILE__, __LINE__
            def #{name}=(new_#{name})
              attributes[:#{name}] = if new_#{name}.nil? || new_#{name} == "" || new_#{name}.is_a?(::Time)
                new_#{name}
              elsif ::String === new_#{name}
                ::Time.parse(new_#{name})
              elsif new_#{name}.respond_to?(:to_time)
                new_#{name}.to_time
              else
                ::Time.parse(new_#{name})
              end
            end
        EOS
      end
    end
  end
end
