module Chewy
  module Runtime
    class Version
      include Comparable
      attr_reader :major, :minor, :patch

      def initialize(version)
        @major, @minor, @patch = *(version.to_s.split('.', 3) + [0] * 3).first(3).map(&:to_i)
      end

      def to_s
        [major, minor, patch].join('.')
      end

      def <=>(other)
        other = self.class.new(other) unless other.is_a?(self.class)
        [
          major <=> other.major,
          minor <=> other.minor,
          patch <=> other.patch
        ].detect(&:nonzero?) || 0
      end
    end
  end
end
