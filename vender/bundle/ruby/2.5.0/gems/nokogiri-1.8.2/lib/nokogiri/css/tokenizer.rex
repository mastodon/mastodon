module Nokogiri
module CSS
class Tokenizer # :nodoc:

macro
  nl        \n|\r\n|\r|\f
  w         [\s]*
  nonascii  [^\0-\177]
  num       -?([0-9]+|[0-9]*\.[0-9]+)
  unicode   \\[0-9A-Fa-f]{1,6}(\r\n|[\s])?

  escape    {unicode}|\\[^\n\r\f0-9A-Fa-f]
  nmchar    [_A-Za-z0-9-]|{nonascii}|{escape}
  nmstart   [_A-Za-z]|{nonascii}|{escape}
  ident     [-@]?({nmstart})({nmchar})*
  name      ({nmchar})+
  string1   "([^\n\r\f"]|{nl}|{nonascii}|{escape})*"
  string2   '([^\n\r\f']|{nl}|{nonascii}|{escape})*'
  string    {string1}|{string2}

rule

# [:state]  pattern  [actions]

            has\({w}         { [:HAS, text] }
            {ident}\({w}     { [:FUNCTION, text] }
            {ident}          { [:IDENT, text] }
            \#{name}         { [:HASH, text] }
            {w}~={w}         { [:INCLUDES, text] }
            {w}\|={w}        { [:DASHMATCH, text] }
            {w}\^={w}        { [:PREFIXMATCH, text] }
            {w}\$={w}        { [:SUFFIXMATCH, text] }
            {w}\*={w}        { [:SUBSTRINGMATCH, text] }
            {w}!={w}         { [:NOT_EQUAL, text] }
            {w}={w}          { [:EQUAL, text] }
            {w}\)            { [:RPAREN, text] }
            \[{w}            { [:LSQUARE, text] }
            {w}\]            { [:RSQUARE, text] }
            {w}\+{w}         { [:PLUS, text] }
            {w}>{w}          { [:GREATER, text] }
            {w},{w}          { [:COMMA, text] }
            {w}~{w}          { [:TILDE, text] }
            \:not\({w}       { [:NOT, text] }
            {num}            { [:NUMBER, text] }
            {w}\/\/{w}       { [:DOUBLESLASH, text] }
            {w}\/{w}         { [:SLASH, text] }
            
            U\+[0-9a-f?]{1,6}(-[0-9a-f]{1,6})?  {[:UNICODE_RANGE, text] }
            
            [\s]+            { [:S, text] }
            {string}         { [:STRING, text] }
            .                { [text, text] }
end
end
end
