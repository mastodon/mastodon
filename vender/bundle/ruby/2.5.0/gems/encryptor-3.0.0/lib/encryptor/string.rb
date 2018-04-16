module Encryptor
  # Adds <tt>encrypt</tt> and <tt>decrypt</tt> methods to strings
  module String
    # Returns a new string containing the encrypted version of itself
    def encrypt(options = {})
      Encryptor.encrypt(options.merge(value: self))
    end

    # Replaces the contents of a string with the encrypted version of itself
    def encrypt!(options ={})
      replace encrypt(options)
    end

    # Returns a new string containing the decrypted version of itself
    def decrypt(options = {})
      Encryptor.decrypt(options.merge(value: self))
    end

    # Replaces the contents of a string with the decrypted version of itself
    def decrypt!(options = {})
      replace decrypt(options)
    end
  end
end