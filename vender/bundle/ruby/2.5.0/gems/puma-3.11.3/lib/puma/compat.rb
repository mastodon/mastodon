# Provides code to work properly on 1.8 and 1.9

class String
  unless method_defined? :bytesize
    alias_method :bytesize, :size
  end

  unless method_defined? :byteslice
    def byteslice(*arg)
      enc = self.encoding
      self.dup.force_encoding(Encoding::ASCII_8BIT).slice(*arg).force_encoding(enc)
    end
  end
end
