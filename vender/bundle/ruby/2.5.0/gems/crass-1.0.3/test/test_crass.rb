# encoding: utf-8
require_relative 'support/common'

describe 'Crass' do
  make_my_diffs_pretty!
  parallelize_me!

  it 'parse_properties() should call Crass::Parser.parse_properties' do
    assert_equal(
      CP.parse_properties("a:b; c:d 42!important;\n"),
      Crass.parse_properties("a:b; c:d 42!important;\n")
    )

    assert_equal(
      CP.parse_properties(";; /**/ ; ;", :preserve_comments => true),
      Crass.parse_properties(";; /**/ ; ;", :preserve_comments => true)
    )
  end

  it 'parse() should call Crass::Parser.parse_stylesheet' do
    assert_equal(
      CP.parse_stylesheet(" /**/ .foo {} #bar {}"),
      Crass.parse(" /**/ .foo {} #bar {}")
    )

    assert_equal(
      CP.parse_stylesheet(" /**/ .foo {} #bar {}", :preserve_comments => true),
      Crass.parse(" /**/ .foo {} #bar {}", :preserve_comments => true)
    )
  end
end
