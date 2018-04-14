# encoding: utf-8
require_relative 'common'

# Miscellaneous attempts to sneak maliciously crafted CSS past Sanitize. Some of
# these are courtesy of (or inspired by) the OWASP XSS Filter Evasion Cheat
# Sheet.
#
# https://www.owasp.org/index.php/XSS_Filter_Evasion_Cheat_Sheet

describe 'Malicious CSS' do
  make_my_diffs_pretty!
  parallelize_me!

  before do
    @s = Sanitize::CSS.new(Sanitize::Config::RELAXED)
  end

  it 'should not be possible to inject an expression by munging it with a comment' do
    @s.properties(%[width:expr/*XSS*/ession(alert('XSS'))]).
      must_equal ''

    @s.properties(%[width:ex/*XSS*//*/*/pression(alert("XSS"))]).
      must_equal ''
  end

  it 'should not be possible to inject an expression by munging it with a newline' do
    @s.properties(%[width:\nexpression(alert('XSS'));]).
      must_equal ''
  end

  it 'should not allow the javascript protocol' do
    @s.properties(%[background-image:url("javascript:alert('XSS')");]).
      must_equal ''

    Sanitize.fragment(%[<div style="background-image: url(&#1;javascript:alert('XSS'))">],
      Sanitize::Config::RELAXED).must_equal '<div></div>'
  end

  it 'should not allow behaviors' do
    @s.properties(%[behavior: url(xss.htc);]).must_equal ''
  end
end
