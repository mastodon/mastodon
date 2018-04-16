module MessagePack

  class UnpackError < StandardError
  end

  class MalformedFormatError < UnpackError
  end

  class StackError < UnpackError
  end

  class UnexpectedTypeError < UnpackError
    include TypeError
  end

  class UnknownExtTypeError < UnpackError
    include TypeError
  end
end
