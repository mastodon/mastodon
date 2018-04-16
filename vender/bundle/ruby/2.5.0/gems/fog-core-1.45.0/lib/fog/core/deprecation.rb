module Fog
  module Deprecation
    def deprecate(older, newer)
      module_eval <<-EOS, __FILE__, __LINE__
        def #{older}(*args)
          Fog::Logger.deprecation("#{self} => ##{older} is deprecated, use ##{newer} instead [light_black](#{caller.first})[/]")
          send(:#{newer}, *args)
        end
      EOS
    end

    def self_deprecate(older, newer)
      module_eval <<-EOS, __FILE__, __LINE__
        def self.#{older}(*args)
          Fog::Logger.deprecation("#{self} => ##{older} is deprecated, use ##{newer} instead [light_black](#{caller.first})[/]")
          send(:#{newer}, *args)
        end
      EOS
    end
  end
end
