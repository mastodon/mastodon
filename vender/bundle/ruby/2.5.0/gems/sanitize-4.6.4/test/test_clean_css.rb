# encoding: utf-8
require_relative 'common'

describe 'Sanitize::Transformers::CSS::CleanAttribute' do
  make_my_diffs_pretty!
  parallelize_me!

  before do
    @s = Sanitize.new(Sanitize::Config::RELAXED)
  end

  it 'should sanitize CSS properties in style attributes' do
    @s.fragment(%[
      <div style="color: #fff; width: expression(alert(1)); /* <-- evil! */"></div>
    ].strip).must_equal %[
      <div style="color: #fff;  /* &lt;-- evil! */"></div>
    ].strip
  end

  it 'should remove the style attribute if the sanitized CSS is empty' do
    @s.fragment('<div style="width: expression(alert(1))"></div>').
      must_equal '<div></div>'
  end
end

describe 'Sanitize::Transformers::CSS::CleanElement' do
  make_my_diffs_pretty!
  parallelize_me!

  before do
    @s = Sanitize.new(Sanitize::Config::RELAXED)
  end

  it 'should sanitize CSS stylesheets in <style> elements' do
    html = %[
      <style>@import url(evil.css);
      /* Yay CSS! */
      .foo { color: #fff; }
      #bar { background: url(yay.jpg); bogus: wtf; }
      .evil { width: expression(xss()); }

      @media screen (max-width:480px) {
        .foo { width: 400px; }
        #bar:not(.baz) { height: 100px; }
      }
      </style>
    ].strip

    @s.fragment(html).must_equal %[
      <style>
      /* Yay CSS! */
      .foo { color: #fff; }
      #bar { background: url(yay.jpg);  }
      .evil {  }

      @media screen (max-width:480px) {
        .foo { width: 400px; }
        #bar:not(.baz) { height: 100px; }
      }
      </style>
    ].strip
  end

  it 'should remove the <style> element if the sanitized CSS is empty' do
    @s.fragment('<style></style>').must_equal ''
  end
end
