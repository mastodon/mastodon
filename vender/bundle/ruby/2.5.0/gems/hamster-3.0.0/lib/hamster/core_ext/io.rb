require "hamster/list"

# Monkey-patches to Ruby's built-in `IO` class.
# @see http://www.ruby-doc.org/core/IO.html
class IO
  # Return a lazy list of "records" read from this IO stream.
  # "Records" are delimited by `$/`, the global input record separator string.
  # By default, it is `"\n"`, a newline.
  #
  # @return [List]
  def to_list(sep = $/) # global input record separator
    Hamster::LazyList.new do
      line = gets(sep)
      if line
        Hamster::Cons.new(line, to_list)
      else
        EmptyList
      end
    end
  end
end
