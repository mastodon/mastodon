module Twitter
  # This module lazily defines constants of the form Uxxxx for all Unicode
  # codepoints from U0000 to U10FFFF. The value of each constant is the
  # UTF-8 string for the codepoint.
  # Examples:
  #   copyright = Unicode::U00A9
  #   euro = Unicode::U20AC
  #   infinity = Unicode::U221E
  #
  module Unicode
    CODEPOINT_REGEX = /^U_?([0-9a-fA-F]{4,5}|10[0-9a-fA-F]{4})$/

    def self.const_missing(name)
      # Check that the constant name is of the right form: U0000 to U10FFFF
      if name.to_s =~ CODEPOINT_REGEX
        # Convert the codepoint to an immutable UTF-8 string,
        # define a real constant for that value and return the value
        #p name, name.class
        const_set(name, [$1.to_i(16)].pack("U").freeze)
      else  # Raise an error for constants that are not Unicode.
        raise NameError, "Uninitialized constant: Unicode::#{name}"
      end
    end
  end

end
