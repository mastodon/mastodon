# -*- ruby encoding: utf-8 -*-

##
# Class Net::LDAP::Filter is used to constrain LDAP searches. An object of
# this class is passed to Net::LDAP#search in the parameter :filter.
#
# Net::LDAP::Filter supports the complete set of search filters available in
# LDAP, including conjunction, disjunction and negation (AND, OR, and NOT).
# This class supplants the (infamous) RFC 2254 standard notation for
# specifying LDAP search filters.
#--
# NOTE: This wording needs to change as we will be supporting LDAPv3 search
# filter strings (RFC 4515).
#++
#
# Here's how to code the familiar "objectclass is present" filter:
#  f = Net::LDAP::Filter.present("objectclass")
#
# The object returned by this code can be passed directly to the
# <tt>:filter</tt> parameter of Net::LDAP#search.
#
# See the individual class and instance methods below for more examples.
class Net::LDAP::Filter
  ##
  # Known filter types.
  FilterTypes = [:ne, :eq, :ge, :le, :and, :or, :not, :ex, :bineq]

  def initialize(op, left, right) #:nodoc:
    unless FilterTypes.include?(op)
      raise Net::LDAP::OperatorError, "Invalid or unsupported operator #{op.inspect} in LDAP Filter."
    end
    @op = op
    @left = left
    @right = right
  end

  class << self
    # We don't want filters created except using our custom constructors.
    private :new

    ##
    # Creates a Filter object indicating that the value of a particular
    # attribute must either be present or match a particular string.
    #
    # Specifying that an attribute is 'present' means only directory entries
    # which contain a value for the particular attribute will be selected by
    # the filter. This is useful in case of optional attributes such as
    # <tt>mail.</tt> Presence is indicated by giving the value "*" in the
    # second parameter to #eq. This example selects only entries that have
    # one or more values for <tt>sAMAccountName:</tt>
    #
    #   f = Net::LDAP::Filter.eq("sAMAccountName", "*")
    #
    # To match a particular range of values, pass a string as the second
    # parameter to #eq. The string may contain one or more "*" characters as
    # wildcards: these match zero or more occurrences of any character. Full
    # regular-expressions are <i>not</i> supported due to limitations in the
    # underlying LDAP protocol. This example selects any entry with a
    # <tt>mail</tt> value containing the substring "anderson":
    #
    #   f = Net::LDAP::Filter.eq("mail", "*anderson*")
    #
    # This filter does not perform any escaping
    def eq(attribute, value)
      new(:eq, attribute, value)
    end

    ##
    # Creates a Filter object indicating a binary comparison.
    # this prevents the search data from being forced into a UTF-8 string.
    #
    # This is primarily used for Microsoft Active Directory to compare
    # GUID values.
    #
    #    # for guid represented as hex charecters
    #    guid = "6a31b4a12aa27a41aca9603f27dd5116"
    #    guid_bin = [guid].pack("H*")
    #    f = Net::LDAP::Filter.bineq("objectGUID", guid_bin)
    #
    # This filter does not perform any escaping.
    def bineq(attribute, value)
      new(:bineq, attribute, value)
    end

    ##
    # Creates a Filter object indicating extensible comparison. This Filter
    # object is currently considered EXPERIMENTAL.
    #
    #   sample_attributes = ['cn:fr', 'cn:fr.eq',
    #     'cn:1.3.6.1.4.1.42.2.27.9.4.49.1.3', 'cn:dn:fr', 'cn:dn:fr.eq']
    #   attr = sample_attributes.first # Pick an extensible attribute
    #   value = 'roberts'
    #
    #   filter = "#{attr}:=#{value}" # Basic String Filter
    #   filter = Net::LDAP::Filter.ex(attr, value) # Net::LDAP::Filter
    #
    #   # Perform a search with the Extensible Match Filter
    #   Net::LDAP.search(:filter => filter)
    #--
    # The LDIF required to support the above examples on the OpenDS LDAP
    # server:
    #
    #   version: 1
    #
    #   dn: dc=example,dc=com
    #   objectClass: domain
    #   objectClass: top
    #   dc: example
    #
    #   dn: ou=People,dc=example,dc=com
    #   objectClass: organizationalUnit
    #   objectClass: top
    #   ou: People
    #
    #   dn: uid=1,ou=People,dc=example,dc=com
    #   objectClass: person
    #   objectClass: organizationalPerson
    #   objectClass: inetOrgPerson
    #   objectClass: top
    #   cn:: csO0YsOpcnRz
    #   sn:: YsO0YiByw7Riw6lydHM=
    #   givenName:: YsO0Yg==
    #   uid: 1
    #
    # =Refs:
    # * http://www.ietf.org/rfc/rfc2251.txt
    # * http://www.novell.com/documentation/edir88/edir88/?page=/documentation/edir88/edir88/data/agazepd.html
    # * https://docs.opends.org/2.0/page/SearchingUsingInternationalCollationRules
    #++
    def ex(attribute, value)
      new(:ex, attribute, value)
    end

    ##
    # Creates a Filter object indicating that a particular attribute value
    # is either not present or does not match a particular string; see
    # Filter::eq for more information.
    #
    # This filter does not perform any escaping
    def ne(attribute, value)
      new(:ne, attribute, value)
    end

    ##
    # Creates a Filter object indicating that the value of a particular
    # attribute must match a particular string. The attribute value is
    # escaped, so the "*" character is interpreted literally.
    def equals(attribute, value)
      new(:eq, attribute, escape(value))
    end

    ##
    # Creates a Filter object indicating that the value of a particular
    # attribute must begin with a particular string. The attribute value is
    # escaped, so the "*" character is interpreted literally.
    def begins(attribute, value)
      new(:eq, attribute, escape(value) + "*")
    end

    ##
    # Creates a Filter object indicating that the value of a particular
    # attribute must end with a particular string. The attribute value is
    # escaped, so the "*" character is interpreted literally.
    def ends(attribute, value)
      new(:eq, attribute, "*" + escape(value))
    end

    ##
    # Creates a Filter object indicating that the value of a particular
    # attribute must contain a particular string. The attribute value is
    # escaped, so the "*" character is interpreted literally.
    def contains(attribute, value)
      new(:eq, attribute, "*" + escape(value) + "*")
    end

    ##
    # Creates a Filter object indicating that a particular attribute value
    # is greater than or equal to the specified value.
    def ge(attribute, value)
      new(:ge, attribute, value)
    end

    ##
    # Creates a Filter object indicating that a particular attribute value
    # is less than or equal to the specified value.
    def le(attribute, value)
      new(:le, attribute, value)
    end

    ##
    # Joins two or more filters so that all conditions must be true. Calling
    # <tt>Filter.join(left, right)</tt> is the same as <tt>left &
    # right</tt>.
    #
    #   # Selects only entries that have an <tt>objectclass</tt> attribute.
    #   x = Net::LDAP::Filter.present("objectclass")
    #   # Selects only entries that have a <tt>mail</tt> attribute that begins
    #   # with "George".
    #   y = Net::LDAP::Filter.eq("mail", "George*")
    #   # Selects only entries that meet both conditions above.
    #   z = Net::LDAP::Filter.join(x, y)
    def join(left, right)
      new(:and, left, right)
    end

    ##
    # Creates a disjoint comparison between two or more filters. Selects
    # entries where either the left or right side are true. Calling
    # <tt>Filter.intersect(left, right)</tt> is the same as <tt>left |
    # right</tt>.
    #
    #   # Selects only entries that have an <tt>objectclass</tt> attribute.
    #   x = Net::LDAP::Filter.present("objectclass")
    #   # Selects only entries that have a <tt>mail</tt> attribute that begins
    #   # with "George".
    #   y = Net::LDAP::Filter.eq("mail", "George*")
    #   # Selects only entries that meet either condition above.
    #   z = x | y
    def intersect(left, right)
      new(:or, left, right)
    end

    ##
    # Negates a filter. Calling <tt>Fitler.negate(filter)</tt> i s the same
    # as <tt>~filter</tt>.
    #
    #   # Selects only entries that do not have an <tt>objectclass</tt>
    #   # attribute.
    #   x = ~Net::LDAP::Filter.present("objectclass")
    def negate(filter)
      new(:not, filter, nil)
    end

    ##
    # This is a synonym for #eq(attribute, "*"). Also known as #present and
    # #pres.
    def present?(attribute)
      eq(attribute, "*")
    end
    alias_method :present, :present?
    alias_method :pres, :present?

    # http://tools.ietf.org/html/rfc4515 lists these exceptions from UTF1
    # charset for filters. All of the following must be escaped in any normal
    # string using a single backslash ('\') as escape.
    #
    ESCAPES = {
      "\0" => '00', # NUL            = %x00 ; null character
      '*'  => '2A', # ASTERISK       = %x2A ; asterisk ("*")
      '('  => '28', # LPARENS        = %x28 ; left parenthesis ("(")
      ')'  => '29', # RPARENS        = %x29 ; right parenthesis (")")
      '\\' => '5C', # ESC            = %x5C ; esc (or backslash) ("\")
    }
    # Compiled character class regexp using the keys from the above hash.
    ESCAPE_RE = Regexp.new(
      "[" +
      ESCAPES.keys.map { |e| Regexp.escape(e) }.join +
      "]")

    ##
    # Escape a string for use in an LDAP filter
    def escape(string)
      string.gsub(ESCAPE_RE) { |char| "\\" + ESCAPES[char] }
    end

    ##
    # Converts an LDAP search filter in BER format to an Net::LDAP::Filter
    # object. The incoming BER object most likely came to us by parsing an
    # LDAP searchRequest PDU. See also the comments under #to_ber, including
    # the grammar snippet from the RFC.
    #--
    # We're hardcoding the BER constants from the RFC. These should be
    # broken out insto constants.
    def parse_ber(ber)
      case ber.ber_identifier
      when 0xa0 # context-specific constructed 0, "and"
        ber.map { |b| parse_ber(b) }.inject { |memo, obj| memo & obj }
      when 0xa1 # context-specific constructed 1, "or"
        ber.map { |b| parse_ber(b) }.inject { |memo, obj| memo | obj }
      when 0xa2 # context-specific constructed 2, "not"
        ~parse_ber(ber.first)
      when 0xa3 # context-specific constructed 3, "equalityMatch"
        if ber.last == "*"
        else
          eq(ber.first, ber.last)
        end
      when 0xa4 # context-specific constructed 4, "substring"
        str = ""
        final = false
        ber.last.each do |b|
          case b.ber_identifier
          when 0x80 # context-specific primitive 0, SubstringFilter "initial"
            raise Net::LDAP::SubstringFilterError, "Unrecognized substring filter; bad initial value." if str.length > 0
            str += escape(b)
          when 0x81 # context-specific primitive 0, SubstringFilter "any"
            str += "*#{escape(b)}"
          when 0x82 # context-specific primitive 0, SubstringFilter "final"
            str += "*#{escape(b)}"
            final = true
          end
        end
        str += "*" unless final
        eq(ber.first.to_s, str)
      when 0xa5 # context-specific constructed 5, "greaterOrEqual"
        ge(ber.first.to_s, ber.last.to_s)
      when 0xa6 # context-specific constructed 6, "lessOrEqual"
        le(ber.first.to_s, ber.last.to_s)
      when 0x87 # context-specific primitive 7, "present"
        # call to_s to get rid of the BER-identifiedness of the incoming string.
        present?(ber.to_s)
      when 0xa9 # context-specific constructed 9, "extensible comparison"
        raise Net::LDAP::SearchFilterError, "Invalid extensible search filter, should be at least two elements" if ber.size < 2

        # Reassembles the extensible filter parts
        # (["sn", "2.4.6.8.10", "Barbara Jones", '1'])
        type = value = dn = rule = nil
        ber.each do |element|
          case element.ber_identifier
            when 0x81 then rule=element
            when 0x82 then type=element
            when 0x83 then value=element
            when 0x84 then dn='dn'
          end
        end

        attribute = ''
        attribute << type if type
        attribute << ":#{dn}" if dn
        attribute << ":#{rule}" if rule

        ex(attribute, value)
      else
        raise Net::LDAP::BERInvalidError, "Invalid BER tag-value (#{ber.ber_identifier}) in search filter."
      end
    end

    ##
    # Converts an LDAP filter-string (in the prefix syntax specified in RFC-2254)
    # to a Net::LDAP::Filter.
    def construct(ldap_filter_string)
      FilterParser.parse(ldap_filter_string)
    end
    alias_method :from_rfc2254, :construct
    alias_method :from_rfc4515, :construct

    ##
    # Convert an RFC-1777 LDAP/BER "Filter" object to a Net::LDAP::Filter
    # object.
    #--
    # TODO, we're hardcoding the RFC-1777 BER-encodings of the various
    # filter types. Could pull them out into a constant.
    #++
    def parse_ldap_filter(obj)
      case obj.ber_identifier
      when 0x87 # present. context-specific primitive 7.
        eq(obj.to_s, "*")
      when 0xa3 # equalityMatch. context-specific constructed 3.
        eq(obj[0], obj[1])
      else
        raise Net::LDAP::SearchFilterTypeUnknownError, "Unknown LDAP search-filter type: #{obj.ber_identifier}"
      end
    end
  end

  ##
  # Joins two or more filters so that all conditions must be true.
  #
  #   # Selects only entries that have an <tt>objectclass</tt> attribute.
  #   x = Net::LDAP::Filter.present("objectclass")
  #   # Selects only entries that have a <tt>mail</tt> attribute that begins
  #   # with "George".
  #   y = Net::LDAP::Filter.eq("mail", "George*")
  #   # Selects only entries that meet both conditions above.
  #   z = x & y
  def &(filter)
    self.class.join(self, filter)
  end

  ##
  # Creates a disjoint comparison between two or more filters. Selects
  # entries where either the left or right side are true.
  #
  #   # Selects only entries that have an <tt>objectclass</tt> attribute.
  #   x = Net::LDAP::Filter.present("objectclass")
  #   # Selects only entries that have a <tt>mail</tt> attribute that begins
  #   # with "George".
  #   y = Net::LDAP::Filter.eq("mail", "George*")
  #   # Selects only entries that meet either condition above.
  #   z = x | y
  def |(filter)
    self.class.intersect(self, filter)
  end

  ##
  # Negates a filter.
  #
  #   # Selects only entries that do not have an <tt>objectclass</tt>
  #   # attribute.
  #   x = ~Net::LDAP::Filter.present("objectclass")
  def ~@
    self.class.negate(self)
  end

  ##
  # Equality operator for filters, useful primarily for constructing unit tests.
  def ==(filter)
    # 20100320 AZ: We need to come up with a better way of doing this. This
    # is just nasty.
    str = "[@op,@left,@right]"
    self.instance_eval(str) == filter.instance_eval(str)
  end

  def to_raw_rfc2254
    case @op
    when :ne
      "!(#{@left}=#{@right})"
    when :eq, :bineq
      "#{@left}=#{@right}"
    when :ex
      "#{@left}:=#{@right}"
    when :ge
      "#{@left}>=#{@right}"
    when :le
      "#{@left}<=#{@right}"
    when :and
      "&(#{@left.to_raw_rfc2254})(#{@right.to_raw_rfc2254})"
    when :or
      "|(#{@left.to_raw_rfc2254})(#{@right.to_raw_rfc2254})"
    when :not
      "!(#{@left.to_raw_rfc2254})"
    end
  end

  ##
  # Converts the Filter object to an RFC 2254-compatible text format.
  def to_rfc2254
    "(#{to_raw_rfc2254})"
  end

  def to_s
    to_rfc2254
  end

  ##
  # Converts the filter to BER format.
  #--
  # Filter ::=
  #     CHOICE {
  #         and             [0] SET OF Filter,
  #         or              [1] SET OF Filter,
  #         not             [2] Filter,
  #         equalityMatch   [3] AttributeValueAssertion,
  #         substrings      [4] SubstringFilter,
  #         greaterOrEqual  [5] AttributeValueAssertion,
  #         lessOrEqual     [6] AttributeValueAssertion,
  #         present         [7] AttributeType,
  #         approxMatch     [8] AttributeValueAssertion,
  #         extensibleMatch [9] MatchingRuleAssertion
  #     }
  #
  # SubstringFilter ::=
  #     SEQUENCE {
  #         type               AttributeType,
  #         SEQUENCE OF CHOICE {
  #             initial        [0] LDAPString,
  #             any            [1] LDAPString,
  #             final          [2] LDAPString
  #         }
  #     }
  #
  # MatchingRuleAssertion ::=
  #     SEQUENCE {
  #       matchingRule    [1] MatchingRuleId OPTIONAL,
  #       type            [2] AttributeDescription OPTIONAL,
  #       matchValue      [3] AssertionValue,
  #       dnAttributes    [4] BOOLEAN DEFAULT FALSE
  #     }
  #
  # Matching Rule Suffixes
  #     Less than   [.1] or .[lt]
  #     Less than or equal to  [.2] or [.lte]
  #     Equality  [.3] or  [.eq] (default)
  #     Greater than or equal to  [.4] or [.gte]
  #     Greater than  [.5] or [.gt]
  #     Substring  [.6] or  [.sub]
  #
  #++
  def to_ber
    case @op
    when :eq
      if @right == "*" # presence test
        @left.to_s.to_ber_contextspecific(7)
      elsif @right =~ /[*]/ # substring
        # Parsing substrings is a little tricky. We use String#split to
        # break a string into substrings delimited by the * (star)
        # character. But we also need to know whether there is a star at the
        # head and tail of the string, so we use a limit parameter value of
        # -1: "If negative, there is no limit to the number of fields
        # returned, and trailing null fields are not suppressed."
        #
        # 20100320 AZ: This is much simpler than the previous verison. Also,
        # unnecessary regex escaping has been removed.

        ary = @right.split(/[*]+/, -1)

        if ary.first.empty?
          first = nil
          ary.shift
        else
          first = unescape(ary.shift).to_ber_contextspecific(0)
        end

        if ary.last.empty?
          last = nil
          ary.pop
        else
          last = unescape(ary.pop).to_ber_contextspecific(2)
        end

        seq = ary.map { |e| unescape(e).to_ber_contextspecific(1) }
        seq.unshift first if first
        seq.push last if last

        [@left.to_s.to_ber, seq.to_ber].to_ber_contextspecific(4)
      else # equality
        [@left.to_s.to_ber, unescape(@right).to_ber].to_ber_contextspecific(3)
      end
    when :bineq
      # make sure data is not forced to UTF-8
      [@left.to_s.to_ber, unescape(@right).to_ber_bin].to_ber_contextspecific(3)
    when :ex
      seq = []

      unless @left =~ /^([-;\w]*)(:dn)?(:(\w+|[.\w]+))?$/
        raise Net::LDAP::BadAttributeError, "Bad attribute #{@left}"
      end
      type, dn, rule = $1, $2, $4

      seq << rule.to_ber_contextspecific(1) unless rule.to_s.empty? # matchingRule
      seq << type.to_ber_contextspecific(2) unless type.to_s.empty? # type
      seq << unescape(@right).to_ber_contextspecific(3) # matchingValue
      seq << "1".to_ber_contextspecific(4) unless dn.to_s.empty? # dnAttributes

      seq.to_ber_contextspecific(9)
    when :ge
      [@left.to_s.to_ber, unescape(@right).to_ber].to_ber_contextspecific(5)
    when :le
      [@left.to_s.to_ber, unescape(@right).to_ber].to_ber_contextspecific(6)
    when :ne
      [self.class.eq(@left, @right).to_ber].to_ber_contextspecific(2)
    when :and
      ary = [@left.coalesce(:and), @right.coalesce(:and)].flatten
      ary.map(&:to_ber).to_ber_contextspecific(0)
    when :or
      ary = [@left.coalesce(:or), @right.coalesce(:or)].flatten
      ary.map(&:to_ber).to_ber_contextspecific(1)
    when :not
      [@left.to_ber].to_ber_contextspecific(2)
    end
  end

  ##
  # Perform filter operations against a user-supplied block. This is useful
  # when implementing an LDAP directory server. The caller's block will be
  # called with two arguments: first, a symbol denoting the "operation" of
  # the filter; and second, an array consisting of arguments to the
  # operation. The user-supplied block (which is MANDATORY) should perform
  # some desired application-defined processing, and may return a
  # locally-meaningful object that will appear as a parameter in the :and,
  # :or and :not operations detailed below.
  #
  # A typical object to return from the user-supplied block is an array of
  # Net::LDAP::Filter objects.
  #
  # These are the possible values that may be passed to the user-supplied
  # block:
  #   * :equalityMatch (the arguments will be an attribute name and a value
  #     to be matched);
  #   * :substrings (two arguments: an attribute name and a value containing
  #     one or more "*" characters);
  #   * :present (one argument: an attribute name);
  #   * :greaterOrEqual (two arguments: an attribute name and a value to be
  #     compared against);
  #   * :lessOrEqual (two arguments: an attribute name and a value to be
  #     compared against);
  #   * :and (two or more arguments, each of which is an object returned
  #     from a recursive call to #execute, with the same block;
  #   * :or (two or more arguments, each of which is an object returned from
  #     a recursive call to #execute, with the same block; and
  #   * :not (one argument, which is an object returned from a recursive
  #     call to #execute with the the same block.
  def execute(&block)
    case @op
    when :eq
      if @right == "*"
        yield :present, @left
      elsif @right.index '*'
        yield :substrings, @left, @right
      else
        yield :equalityMatch, @left, @right
      end
    when :ge
      yield :greaterOrEqual, @left, @right
    when :le
      yield :lessOrEqual, @left, @right
    when :or, :and
      yield @op, (@left.execute(&block)), (@right.execute(&block))
    when :not
      yield @op, (@left.execute(&block))
    end || []
  end

  ##
  # This is a private helper method for dealing with chains of ANDs and ORs
  # that are longer than two. If BOTH of our branches are of the specified
  # type of joining operator, then return both of them as an array (calling
  # coalesce recursively). If they're not, then return an array consisting
  # only of self.
  def coalesce(operator) #:nodoc:
    if @op == operator
      [@left.coalesce(operator), @right.coalesce(operator)]
    else
      [self]
    end
  end

  ##
  #--
  # We got a hash of attribute values.
  # Do we match the attributes?
  # Return T/F, and call match recursively as necessary.
  #++
  def match(entry)
    case @op
    when :eq
      if @right == "*"
        l = entry[@left] and l.length > 0
      else
        l = entry[@left] and l = Array(l) and l.index(@right)
      end
    else
      raise Net::LDAP::FilterTypeUnknownError, "Unknown filter type in match: #{@op}"
    end
  end

  ##
  # Converts escaped characters (e.g., "\\28") to unescaped characters
  def unescape(right)
    right.to_s.gsub(/\\([a-fA-F\d]{2})/) { [$1.hex].pack("U") }
  end
  private :unescape

  ##
  # Parses RFC 2254-style string representations of LDAP filters into Filter
  # object hierarchies.
  class FilterParser #:nodoc:
    ##
    # The constructed filter.
    attr_reader :filter

    class << self
      private :new

      ##
      # Construct a filter tree from the provided string and return it.
      def parse(ldap_filter_string)
        new(ldap_filter_string).filter
      end
    end

    def initialize(str)
      require 'strscan' # Don't load strscan until we need it.
      @filter = parse(StringScanner.new(str))
      raise Net::LDAP::FilterSyntaxInvalidError, "Invalid filter syntax." unless @filter
    end

    ##
    # Parse the string contained in the StringScanner provided. Parsing
    # tries to parse a standalone expression first. If that fails, it tries
    # to parse a parenthesized expression.
    def parse(scanner)
      parse_filter_branch(scanner) or parse_paren_expression(scanner)
    end
    private :parse

    ##
    # Join ("&") and intersect ("|") operations are presented in branches.
    # That is, the expression <tt>(&(test1)(test2)</tt> has two branches:
    # test1 and test2. Each of these is parsed separately and then pushed
    # into a branch array for filter merging using the parent operation.
    #
    # This method parses the branch text out into an array of filter
    # objects.
    def parse_branches(scanner)
      branches = []
      while branch = parse_paren_expression(scanner)
        branches << branch
      end
      branches
    end
    private :parse_branches

    ##
    # Join ("&") and intersect ("|") operations are presented in branches.
    # That is, the expression <tt>(&(test1)(test2)</tt> has two branches:
    # test1 and test2. Each of these is parsed separately and then pushed
    # into a branch array for filter merging using the parent operation.
    #
    # This method calls #parse_branches to generate the branch list and then
    # merges them into a single Filter tree by calling the provided
    # operation.
    def merge_branches(op, scanner)
      filter = nil
      branches = parse_branches(scanner)

      if branches.size >= 1
        filter = branches.shift
        while not branches.empty?
          filter = filter.__send__(op, branches.shift)
        end
      end

      filter
    end
    private :merge_branches

    def parse_paren_expression(scanner)
      if scanner.scan(/\s*\(\s*/)
        expr = if scanner.scan(/\s*\&\s*/)
                 merge_branches(:&, scanner)
               elsif scanner.scan(/\s*\|\s*/)
                 merge_branches(:|, scanner)
               elsif scanner.scan(/\s*\!\s*/)
                 br = parse_paren_expression(scanner)
                 ~br if br
               else
                 parse_filter_branch(scanner)
               end

        if expr and scanner.scan(/\s*\)\s*/)
          expr
        end
      end
    end
    private :parse_paren_expression

    ##
    # This parses a given expression inside of parentheses.
    def parse_filter_branch(scanner)
      scanner.scan(/\s*/)
      if token = scanner.scan(/[-\w:.]*[\w]/)
        scanner.scan(/\s*/)
        if op = scanner.scan(/<=|>=|!=|:=|=/)
          scanner.scan(/\s*/)
          if value = scanner.scan(/(?:[-\[\]{}\w*.+\/:@=,#\$%&!'^~\s\xC3\x80-\xCA\xAF]|[^\x00-\x7F]|\\[a-fA-F\d]{2})+/u)
            # 20100313 AZ: Assumes that "(uid=george*)" is the same as
            # "(uid=george* )". The standard doesn't specify, but I can find
            # no examples that suggest otherwise.
            value.strip!
            case op
            when "="
              Net::LDAP::Filter.eq(token, value)
            when "!="
              Net::LDAP::Filter.ne(token, value)
            when "<="
              Net::LDAP::Filter.le(token, value)
            when ">="
              Net::LDAP::Filter.ge(token, value)
            when ":="
              Net::LDAP::Filter.ex(token, value)
            end
          end
        end
      end
    end
    private :parse_filter_branch
  end # class Net::LDAP::FilterParser
end # class Net::LDAP::Filter
