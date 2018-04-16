module Av
  class ParamHash < Hash
    def to_s
      line = []
      self.each do |option, value|
        value = value.join(' ') unless value.is_a?(String)
        line << "-#{option} #{value}"
      end
      line.join(' ')
    end
  end
end