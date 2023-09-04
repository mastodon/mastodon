# frozen_string_literal: true

class HashObject
  def initialize(hash)
    hash.each do |k, v|
      instance_variable_set("@#{k}", v)
      self.class.send(:define_method, k, proc { instance_variable_get("@#{k}") })
    end
  end
end
