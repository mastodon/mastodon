# frozen_string_literal: true
class Module
  # Check for an existing method in the current class before extending.  If
  # the method already exists, then a warning is printed and the extension is
  # not added.  Otherwise the block is yielded and any definitions in the
  # block will take effect.
  #
  # Usage:
  #
  #   class String
  #     rake_extension("xyz") do
  #       def xyz
  #         ...
  #       end
  #     end
  #   end
  #
  def rake_extension(method) # :nodoc:
    if method_defined?(method)
      $stderr.puts "WARNING: Possible conflict with Rake extension: " +
        "#{self}##{method} already exists"
    else
      yield
    end
  end
end
