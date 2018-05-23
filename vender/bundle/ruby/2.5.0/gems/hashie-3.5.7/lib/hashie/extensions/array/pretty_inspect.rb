module Hashie
  module Extensions
    module Array
      module PrettyInspect
        def self.included(base)
          base.send :alias_method, :array_inspect, :inspect
          base.send :alias_method, :inspect, :hashie_inspect
        end

        def hashie_inspect
          ret = "#<#{self.class} ["
          ret << to_a.map(&:inspect).join(', ')
          ret << ']>'
          ret
        end
      end
    end
  end
end
