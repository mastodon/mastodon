class Nokogiri::CSS::Parser

token FUNCTION INCLUDES DASHMATCH LBRACE HASH PLUS GREATER S STRING IDENT
token COMMA NUMBER PREFIXMATCH SUFFIXMATCH SUBSTRINGMATCH TILDE NOT_EQUAL
token SLASH DOUBLESLASH NOT EQUAL RPAREN LSQUARE RSQUARE HAS

rule
  selector
    : selector COMMA simple_selector_1toN {
        result = [val.first, val.last].flatten
      }
    | prefixless_combinator_selector { result = val.flatten }
    | optional_S simple_selector_1toN { result = [val.last].flatten }
    ;
  combinator
    : PLUS { result = :DIRECT_ADJACENT_SELECTOR }
    | GREATER { result = :CHILD_SELECTOR }
    | TILDE { result = :FOLLOWING_SELECTOR }
    | DOUBLESLASH { result = :DESCENDANT_SELECTOR }
    | SLASH { result = :CHILD_SELECTOR }
    ;
  simple_selector
    : element_name hcap_0toN {
        result =  if val[1].nil?
                    val.first
                  else
                    Node.new(:CONDITIONAL_SELECTOR, [val.first, val[1]])
                  end
      }
    | function
    | function pseudo {
        result = Node.new(:CONDITIONAL_SELECTOR, val)
      }
    | function attrib {
        result = Node.new(:CONDITIONAL_SELECTOR, val)
      }
    | hcap_1toN {
        result = Node.new(:CONDITIONAL_SELECTOR,
          [Node.new(:ELEMENT_NAME, ['*']), val.first]
        )
      }
    ;
  prefixless_combinator_selector
    : combinator simple_selector_1toN {
        result = Node.new(val.first, [nil, val.last])
      }
    ;
  simple_selector_1toN
    : simple_selector combinator simple_selector_1toN {
        result = Node.new(val[1], [val.first, val.last])
      }
    | simple_selector S simple_selector_1toN {
        result = Node.new(:DESCENDANT_SELECTOR, [val.first, val.last])
      }
    | simple_selector
    ;
  class
    : '.' IDENT { result = Node.new(:CLASS_CONDITION, [unescape_css_identifier(val[1])]) }
    ;
  element_name
    : namespaced_ident
    | '*' { result = Node.new(:ELEMENT_NAME, val) }
    ;
  namespaced_ident
    : namespace '|' IDENT {
        result = Node.new(:ELEMENT_NAME,
          [[val.first, val.last].compact.join(':')]
        )
      }
    | IDENT {
        name = @namespaces.key?('xmlns') ? "xmlns:#{val.first}" : val.first
        result = Node.new(:ELEMENT_NAME, [name])
      }
    ;
  namespace
    : IDENT { result = val[0] }
    |
    ;
  attrib
    : LSQUARE attrib_name attrib_val_0or1 RSQUARE {
        result = Node.new(:ATTRIBUTE_CONDITION,
          [val[1]] + (val[2] || [])
        )
      }
    | LSQUARE function attrib_val_0or1 RSQUARE {
        result = Node.new(:ATTRIBUTE_CONDITION,
          [val[1]] + (val[2] || [])
        )
      }
    | LSQUARE NUMBER RSQUARE {
        # Non standard, but hpricot supports it.
        result = Node.new(:PSEUDO_CLASS,
          [Node.new(:FUNCTION, ['nth-child(', val[1]])]
        )
      }
    ;
  attrib_name
    : namespace '|' IDENT {
        result = Node.new(:ELEMENT_NAME,
          [[val.first, val.last].compact.join(':')]
        )
      }
    | IDENT {
        # Default namespace is not applied to attributes.
        # So we don't add prefix "xmlns:" as in namespaced_ident.
        result = Node.new(:ELEMENT_NAME, [val.first])
      }
    ;
  function
    : FUNCTION RPAREN {
        result = Node.new(:FUNCTION, [val.first.strip])
      }
    | FUNCTION expr RPAREN {
        result = Node.new(:FUNCTION, [val.first.strip, val[1]].flatten)
      }
    | FUNCTION nth RPAREN {
        result = Node.new(:FUNCTION, [val.first.strip, val[1]].flatten)
      }
    | NOT expr RPAREN {
        result = Node.new(:FUNCTION, [val.first.strip, val[1]].flatten)
      }
    | HAS selector RPAREN {
        result = Node.new(:FUNCTION, [val.first.strip, val[1]].flatten)
      }
    ;
  expr
    : NUMBER COMMA expr { result = [val.first, val.last] }
    | STRING COMMA expr { result = [val.first, val.last] }
    | IDENT COMMA expr { result = [val.first, val.last] }
    | NUMBER
    | STRING
    | IDENT                             # even, odd
      {
        case val[0]
        when 'even'
          result = Node.new(:NTH, ['2','n','+','0'])
        when 'odd'
          result = Node.new(:NTH, ['2','n','+','1'])
        when 'n'
          result = Node.new(:NTH, ['1','n','+','0'])
        else
          # This is not CSS standard.  It allows us to support this:
          # assert_xpath("//a[foo(., @href)]", @parser.parse('a:foo(@href)'))
          # assert_xpath("//a[foo(., @a, b)]", @parser.parse('a:foo(@a, b)'))
          # assert_xpath("//a[foo(., a, 10)]", @parser.parse('a:foo(a, 10)'))
          result = val
        end
      }
    ;
  nth
    : NUMBER IDENT PLUS NUMBER          # 5n+3 -5n+3
      {
        if val[1] == 'n'
          result = Node.new(:NTH, val)
        else
          raise Racc::ParseError, "parse error on IDENT '#{val[1]}'"
        end
      }
    | IDENT PLUS NUMBER {               # n+3, -n+3
        if val[0] == 'n'
          val.unshift("1")
          result = Node.new(:NTH, val)
        elsif val[0] == '-n'
          val[0] = 'n'
          val.unshift("-1")
          result = Node.new(:NTH, val)
        else
          raise Racc::ParseError, "parse error on IDENT '#{val[1]}'"
        end
      }
    | NUMBER IDENT {                    # 5n, -5n, 10n-1
        n = val[1]
        if n[0, 2] == 'n-'
          val[1] = 'n'
          val << "-"
          # b is contained in n as n is the string "n-b"
          val << n[2, n.size]
          result = Node.new(:NTH, val)
        elsif n == 'n'
          val << "+"
          val << "0"
          result = Node.new(:NTH, val)
        else
          raise Racc::ParseError, "parse error on IDENT '#{val[1]}'"
        end
      }
    ;
  pseudo
    : ':' function {
        result = Node.new(:PSEUDO_CLASS, [val[1]])
      }
    | ':' IDENT { result = Node.new(:PSEUDO_CLASS, [val[1]]) }
    ;
  hcap_0toN
    : hcap_1toN
    |
    ;
  hcap_1toN
    : attribute_id hcap_1toN {
        result = Node.new(:COMBINATOR, val)
      }
    | class hcap_1toN {
        result = Node.new(:COMBINATOR, val)
      }
    | attrib hcap_1toN {
        result = Node.new(:COMBINATOR, val)
      }
    | pseudo hcap_1toN {
        result = Node.new(:COMBINATOR, val)
      }
    | negation hcap_1toN {
        result = Node.new(:COMBINATOR, val)
      }
    | attribute_id
    | class
    | attrib
    | pseudo
    | negation
    ;
  attribute_id
    : HASH { result = Node.new(:ID, [unescape_css_identifier(val.first)]) }
    ;
  attrib_val_0or1
    : eql_incl_dash IDENT { result = [val.first, val[1]] }
    | eql_incl_dash STRING { result = [val.first, val[1]] }
    |
    ;
  eql_incl_dash
    : EQUAL           { result = :equal }
    | PREFIXMATCH     { result = :prefix_match }
    | SUFFIXMATCH     { result = :suffix_match }
    | SUBSTRINGMATCH  { result = :substring_match }
    | NOT_EQUAL       { result = :not_equal }
    | INCLUDES        { result = :includes }
    | DASHMATCH       { result = :dash_match }
    ;
  negation
    : NOT negation_arg RPAREN {
        result = Node.new(:NOT, [val[1]])
      }
    ;
  negation_arg
    : element_name
    | element_name hcap_1toN
    | hcap_1toN
    ;
  optional_S
    : S
    |
    ;
end

---- header

require 'nokogiri/css/parser_extras'

---- inner

def unescape_css_identifier(identifier)
  identifier.gsub(/\\(?:([^0-9a-fA-F])|([0-9a-fA-F]{1,6})\s?)/){ |m| $1 || [$2.hex].pack('U') }
end
