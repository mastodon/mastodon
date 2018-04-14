module Temple
  # Exception raised if invalid temple expression is found
  #
  # @api public
  class InvalidExpression < RuntimeError
  end

  # Exception raised if something bad happens in a Temple filter
  #
  # @api public
  class FilterError < RuntimeError
  end
end
