require "hamster/list"

# Monkey-patches to Ruby's built-in `Enumerable` module.
# @see http://www.ruby-doc.org/core/Enumerable.html
module Enumerable
  # Return a new {Hamster::List} populated with the items in this `Enumerable` object.
  # @return [List]
  def to_list
    Hamster::List.from_enum(self)
  end
end
