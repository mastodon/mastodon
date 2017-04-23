if String.method_defined?(:blank_as?)
  class String
    alias_method :blank?, :blank_as?
  end
end
