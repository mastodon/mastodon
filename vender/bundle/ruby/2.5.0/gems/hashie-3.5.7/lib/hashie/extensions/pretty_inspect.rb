module Hashie
  module Extensions
    module PrettyInspect
      def self.included(base)
        base.send :alias_method, :hash_inspect, :inspect
        base.send :alias_method, :inspect, :hashie_inspect
      end

      def hashie_inspect
        ret = "#<#{self.class}"
        keys.sort_by(&:to_s).each do |key|
          ret << " #{key}=#{self[key].inspect}"
        end
        ret << '>'
        ret
      end
    end
  end
end
