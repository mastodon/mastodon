# frozen_string_literal: true

# Originally written by ViaCelestia
# https://github.com/dryruby/json-canonicalization/pull/6

class Numeric
  # This is intended to be compliant with ECMA-262, version 6.0 (ES6)
  #
  # See https://262.ecma-international.org/6.0/#sec-tostring-applied-to-the-number-type
  #
  # JSON does not permit NaN or infinite values, so those raise an error
  def to_json_c14n
    raise RangeError if self.is_a?(Float) && !self.finite?
    return '0' if self.zero?

    # We may or may not be using scientific notation (see https://en.wikipedia.org/wiki/Scientific_notation)
    # at this point, but the terminology is the same. Numbers are represented as a significand
    # (also known as a mantissa) multiplied by 10 raised to an exponent. A number like 1701 may be represented
    # as 1701 * 10^0, 170.1 * 10^1, 17.01 * 10^2, or (in scientific notation) 1.701 * 10^3. ES6 and Ruby don't
    # always agree on when to use scientific notation, but if Ruby has done the conversion, we can use the
    # exponent below when reproducing the behavior in the ES6 spec.
    significand_digits, exponent_digits = self.abs.to_s.split('e', 2)

    integer_digits, fraction_digits = significand_digits.split('.', 2)


    # From the ES6 spec:
    #
    # "The abstract operation ToString converts a Number m to String format as follows ...
    # let n, k, and s be integers such that k ≥ 1, 10k−1 ≤ s < 10k, the Number value for s × 10n−k is m,
    # and k is as small as possible. Note that k is the number of digits in the decimal representation of s,
    # that s is not divisible by 10, and that the least significant digit of s is not necessarily uniquely
    # determined by these criteria."
    #
    # This is just a different sort of exponential notation, but instead of preferring 0 < s < 10 as in
    # scientific notation, here we want s to be an integer, and not divisible by 10. Since we're relying
    # on ruby's existing #to_s, s is just the significand without the decimal or any leading or trailing
    # zeroes
    s = significand_digits.sub('.', '').sub(/^-?0*/, '').sub(/0*$/, '')

    # Once we know s, k is easy
    k = s.length

    # If n is positive, it represents the number of digits (including trailing zeroes) to the left of the
    # decimal. If n is negative or zero, it represents the number of zeroes to the right of the decimal.
    # n-1 is also equal to the exponent used in scientific notation represenations of m, so if we already
    # have that representation, we can use that rather than try to recalculate where the decimal would be
    # If we don't already have an exponent, we just do digit counting rather than using Math.log10(self) or
    # the slightly more precise Math.log2(self)/Math.log2(10) since that can lose precision for values very
    # close to n = 22, like the Integer value 999999999999999700000
    n = if exponent_digits
	  exponent_digits.to_i + 1
	elsif integer_digits.to_i > 0
	  integer_digits.length
	else
	  -fraction_digits.index(/[1-9]/)
	end

    exponent = n - 1

    # Per the spec, positive numbers do not include a sign, but exponents always do
    sign = self.negative? ? '-' : ''
    exponent_sign = exponent.negative? ? '-' : '+'

    if k <= n && n <= 21 # Whole numbers, possibly with trailing zeroes, and < 10^21
      # return the String consisting of the code units of the k digits of the decimal representation of s
      # (in order, with no leading zeroes), followed by n−k occurrences of the code unit 0x0030 (DIGIT ZERO).
      [sign, s, '0' * (n - k)].join
    elsif 0 < n && n <= 21 # Numbers with an integer component < 10^21
      # return the String consisting of the code units of the most significant n digits of the decimal
      # representation of s, followed by the code unit 0x002E (FULL STOP), followed by the code units of the
      # remaining k−n digits of the decimal representation of s.
      [sign, s[0..(n-1)], '.', s[n..-1]].join
    elsif -6 < n && n <= 0 # Fractional numbers to no more than 6 decimal places
      # return the String consisting of the code unit 0x0030 (DIGIT ZERO), followed by the code unit 0x002E
      # (FULL STOP), followed by −n occurrences of the code unit 0x0030 (DIGIT ZERO), followed by the code
      # units of the k digits of the decimal representation of s
      [sign, '0.', '0' * (-n), s].join
    elsif k == 1 # single significant digit outside of -6 < n <= 21
      # return the String consisting of the code unit of the single digit of s, followed by code unit 0x0065
      # (LATIN SMALL LETTER E), followed by the code unit 0x002B (PLUS SIGN) or the code unit 0x002D
      # (HYPHEN-MINUS) according to whether n−1 is positive or negative, followed by the code units of the decimal
      # representation of the integer abs(n−1) (with no leading zeroes).
      #
      # This produces "1e-18", rather than Ruby's default "1.0e-18"
      [sign, s, 'e', exponent_sign, exponent.abs].join
    else # multiple significant digits outside of -6 < n <= 21
      # Return the String consisting of the code units of the most significant digit of the decimal representation
      # of s, followed by code unit 0x002E (FULL STOP), followed by the code units of the remaining k−1 digits of
      # the decimal representation of s, followed by code unit 0x0065 (LATIN SMALL LETTER E), followed by code unit
      # 0x002B (PLUS SIGN) or the code unit 0x002D (HYPHEN-MINUS) according to whether n−1 is positive or negative,
      # followed by the code units of the decimal representation of the integer abs(n−1) (with no leading zeroes).
      [sign, s[0], '.', s[1..-1], 'e', exponent_sign, exponent.abs].join
    end
  end
end
