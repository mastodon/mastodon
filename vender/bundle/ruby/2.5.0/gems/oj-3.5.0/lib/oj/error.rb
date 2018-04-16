
module Oj

  # Inherit Error class from StandardError.
  Error = Class.new(StandardError)

  # Following classes inherit from the Error class.
  # -----------------------------------------------

  # An Exception that is raised as a result of a parse error while parsing a JSON document.
  ParseError = Class.new(Error)

  # An Exception that is raised as a result of a path being too deep.
  DepthError = Class.new(Error)

  # An Exception that is raised if a file fails to load.
  LoadError = Class.new(Error)

  # An Exception that is raised if there is a conflict with mimicing JSON
  MimicError = Class.new(Error)

end # Oj
