require 'rubygems'

unless defined?(TESTDIR)
  TESTDIR = File.dirname(__FILE__)
  LIBDIR  = TESTDIR == '.' ? '../lib' : File.dirname(TESTDIR) + '/lib'
  $: << TESTDIR
  $: << LIBDIR
end

if ENV['COVERAGE']
  require 'coverage'
  require 'simplecov'

  ENV.delete('COVERAGE')
  SimpleCov.instance_eval do
    start do
      add_filter "/test/"
      add_group('Missing'){|src| src.covered_percent < 100}
      add_group('Covered'){|src| src.covered_percent == 100}
    end
  end
end

require 'erubi'
require 'erubi/capture_end'
require 'minitest/spec'
require 'minitest/autorun'

describe Erubi::Engine do
  before do
    @options = {}
  end

  def check_output(input, src, result, &block)
    t = (@options[:engine] || Erubi::Engine).new(input, @options)
    tsrc = t.src
    eval(tsrc, block.binding).must_equal result
    tsrc = tsrc.gsub("'.freeze;", "';") if RUBY_VERSION >= '2.1'
    tsrc.must_equal src
  end

  def setup_foo
    @foo = Object.new
    @foo.instance_variable_set(:@t, self)
    def self.a; @a; end
    def @foo.bar
      @t.a << "a"
      yield
      @t.a << 'b'
      @t.a.buffer.upcase!
    end
  end

  def setup_bar
    def self.bar
      @a << "a"
      yield
      @a << 'b'
      @a.upcase
    end
    def self.baz
      @a << "c"
      yield
      @a << 'd'
      @a * 2
    end
    def self.quux
      @a << "a"
      3.times do |i|
        @a << "c#{i}"
        yield i
        @a << "d#{i}"
      end
      @a << "b"
      @a.upcase
    end
  end

  it "should handle no options" do
    list = ['&\'<>"2']
    check_output(<<END1, <<END2, <<END3){}
<table>
 <tbody>
  <% i = 0
     list.each_with_index do |item, i| %>
  <tr>
   <td><%= i+1 %></td>
   <td><%== item %></td>
  </tr>
 <% end %>
 </tbody>
</table>
<%== i+1 %>
END1
_buf = String.new; _buf << '<table>
 <tbody>
';   i = 0
     list.each_with_index do |item, i| 
 _buf << '  <tr>
   <td>'; _buf << ( i+1 ).to_s; _buf << '</td>
   <td>'; _buf << ::Erubi.h(( item )); _buf << '</td>
  </tr>
';  end 
 _buf << ' </tbody>
</table>
'; _buf << ::Erubi.h(( i+1 )); _buf << '
';
_buf.to_s
END2
<table>
 <tbody>
  <tr>
   <td>1</td>
   <td>&amp;&#39;&lt;&gt;&quot;2</td>
  </tr>
 </tbody>
</table>
1
END3
  end

  it "should strip only whitespace for <%, <%- and <%# tags" do
    check_output(<<END1, <<END2, <<END3){}
  <% 1 %>  
a
  <%- 2 %>  
b
  <%# 3 %>  
c
 /<% 1 %>  
a
/ <%- 2 %>  
b
//<%# 3 %>  
c
  <% 1 %> /
a
  <%- 2 %>/ 
b
  <%# 3 %>//
c
END1
_buf = String.new;   1   
 _buf << 'a
';   2   
 _buf << 'b
';
 _buf << 'c
 /'; 1 ; _buf << '  
'; _buf << 'a
/ '; 2 ; _buf << '  
'; _buf << 'b
//';
 _buf << '  
'; _buf << 'c
'; _buf << '  '; 1 ; _buf << ' /
a
'; _buf << '  '; 2 ; _buf << '/ 
b
'; _buf << '  ';; _buf << '//
c
';
_buf.to_s
END2
a
b
c
 /  
a
/   
b
//  
c
   /
a
  / 
b
  //
c
END3
  end

  it "should handle ensure option" do
    list = ['&\'<>"2']
    @options[:ensure] = true
    @options[:bufvar] = '@a'
    @a = 'bar'
    check_output(<<END1, <<END2, <<END3){}
<table>
 <tbody>
  <% i = 0
     list.each_with_index do |item, i| %>
  <tr>
   <td><%= i+1 %></td>
   <td><%== item %></td>
  </tr>
 <% end %>
 </tbody>
</table>
<%== i+1 %>
END1
begin; __original_outvar = @a if defined?(@a); @a = String.new; @a << '<table>
 <tbody>
';   i = 0
     list.each_with_index do |item, i| 
 @a << '  <tr>
   <td>'; @a << ( i+1 ).to_s; @a << '</td>
   <td>'; @a << ::Erubi.h(( item )); @a << '</td>
  </tr>
';  end 
 @a << ' </tbody>
</table>
'; @a << ::Erubi.h(( i+1 )); @a << '
';
@a.to_s
; ensure
  @a = __original_outvar
end
END2
<table>
 <tbody>
  <tr>
   <td>1</td>
   <td>&amp;&#39;&lt;&gt;&quot;2</td>
  </tr>
 </tbody>
</table>
1
END3
    @a.must_equal 'bar'
  end

  it "should have <%|= with CaptureEndEngine not escape by default" do
    eval(::Erubi::CaptureEndEngine.new('<%|= "&" %><%| %>').src).must_equal '&'
    eval(::Erubi::CaptureEndEngine.new('<%|= "&" %><%| %>', :escape=>false).src).must_equal '&'
    eval(::Erubi::CaptureEndEngine.new('<%|= "&" %><%| %>', :escape_capture=>false).src).must_equal '&'
    eval(::Erubi::CaptureEndEngine.new('<%|= "&" %><%| %>', :escape=>true).src).must_equal '&amp;'
    eval(::Erubi::CaptureEndEngine.new('<%|= "&" %><%| %>', :escape_capture=>true).src).must_equal '&amp;'
  end

  it "should have <%|== with CaptureEndEngine escape by default" do
    eval(::Erubi::CaptureEndEngine.new('<%|== "&" %><%| %>').src).must_equal '&amp;'
    eval(::Erubi::CaptureEndEngine.new('<%|== "&" %><%| %>', :escape=>true).src).must_equal '&'
    eval(::Erubi::CaptureEndEngine.new('<%|== "&" %><%| %>', :escape_capture=>true).src).must_equal '&'
    eval(::Erubi::CaptureEndEngine.new('<%|== "&" %><%| %>', :escape=>false).src).must_equal '&amp;'
    eval(::Erubi::CaptureEndEngine.new('<%|== "&" %><%| %>', :escape_capture=>false).src).must_equal '&amp;'
  end

  [['', false], ['=', true]].each do |ind, escape|
    it "should allow <%|=#{ind} and <%| for capturing with CaptureEndEngine with :escape_capture => #{escape} and :escape => #{!escape}" do
      @options[:bufvar] = '@a'
      @options[:capture] = true
      @options[:escape_capture] = escape
      @options[:escape] = !escape
      @options[:engine] = ::Erubi::CaptureEndEngine
      setup_bar
      check_output(<<END1, <<END2, <<END3){}
<table>
 <tbody>
  <%|=#{ind} bar do %>
   <b><%=#{ind} '&' %></b>
 <%| end %>
 </tbody>
</table>
END1
#{'__erubi = ::Erubi;' unless escape}@a = String.new; @a << '<table>
 <tbody>
'; @a << '  ';begin; (__erubi_stack ||= []) << @a; @a = String.new; __erubi_stack.last << (( bar do  @a << '
'; @a << '   <b>'; @a << #{!escape ? '__erubi' : '::Erubi'}.h(( '&' )); @a << '</b>
'; @a << ' '; end )).to_s; ensure; @a = __erubi_stack.pop; end; @a << '
'; @a << ' </tbody>
</table>
';
@a.to_s
END2
<table>
 <tbody>
  A
   <B>&AMP;</B>
 B
 </tbody>
</table>
END3
    end
  end

  [['', true], ['=', false]].each do |ind, escape|
    it "should allow <%|=#{ind} and <%| for capturing with CaptureEndEngine when with :escape => #{escape}" do
      @options[:bufvar] = '@a'
      @options[:escape] = escape
      @options[:engine] = ::Erubi::CaptureEndEngine
      setup_bar
      check_output(<<END1, <<END2, <<END3){}
<table>
 <tbody>
  <%|=#{ind} bar do %>
   <b><%=#{ind} '&' %></b>
 <%| end %>
 </tbody>
</table>
END1
#{'__erubi = ::Erubi;' if escape}@a = String.new; @a << '<table>
 <tbody>
'; @a << '  ';begin; (__erubi_stack ||= []) << @a; @a = String.new; __erubi_stack.last << #{escape ? '__erubi' : '::Erubi'}.h(( bar do  @a << '
'; @a << '   <b>'; @a << #{escape ? '__erubi' : '::Erubi'}.h(( '&' )); @a << '</b>
'; @a << ' '; end )).to_s; ensure; @a = __erubi_stack.pop; end; @a << '
'; @a << ' </tbody>
</table>
';
@a.to_s
END2
<table>
 <tbody>
  A
   &lt;B&gt;&amp;AMP;&lt;/B&gt;
 B
 </tbody>
</table>
END3
    end

    it "should handle loops in <%|=#{ind} and <%| for capturing with CaptureEndEngine when with :escape => #{escape}" do
      @options[:bufvar] = '@a'
      @options[:escape] = escape
      @options[:engine] = ::Erubi::CaptureEndEngine
      setup_bar
      check_output(<<END1, <<END2, <<END3){}
<table>
 <tbody>
  <%|=#{ind} quux do |i| %>
   <b><%=#{ind} "\#{i}&" %></b>
 <%| end %>
 </tbody>
</table>
END1
#{'__erubi = ::Erubi;' if escape}@a = String.new; @a << '<table>
 <tbody>
'; @a << '  ';begin; (__erubi_stack ||= []) << @a; @a = String.new; __erubi_stack.last << #{escape ? '__erubi' : '::Erubi'}.h(( quux do |i|  @a << '
'; @a << '   <b>'; @a << #{escape ? '__erubi' : '::Erubi'}.h(( "\#{i}&" )); @a << '</b>
'; @a << ' '; end )).to_s; ensure; @a = __erubi_stack.pop; end; @a << '
'; @a << ' </tbody>
</table>
';
@a.to_s
END2
<table>
 <tbody>
  AC0
   &lt;B&gt;0&amp;AMP;&lt;/B&gt;
 D0C1
   &lt;B&gt;1&amp;AMP;&lt;/B&gt;
 D1C2
   &lt;B&gt;2&amp;AMP;&lt;/B&gt;
 D2B
 </tbody>
</table>
END3
    end

    it "should allow <%|=#{ind} and <%| for nested capturing with CaptureEndEngine when with :escape => #{escape}" do
      @options[:bufvar] = '@a'
      @options[:escape] = escape
      @options[:engine] = ::Erubi::CaptureEndEngine
      setup_bar
      check_output(<<END1, <<END2, <<END3){}
<table>
 <tbody>
  <%|=#{ind} bar do %>
   <b><%=#{ind} '&' %></b>
   <%|=#{ind} baz do %>e<%| end %>
 <%| end %>
 </tbody>
</table>
END1
#{'__erubi = ::Erubi;' if escape}@a = String.new; @a << '<table>
 <tbody>
'; @a << '  ';begin; (__erubi_stack ||= []) << @a; @a = String.new; __erubi_stack.last << #{escape ? '__erubi' : '::Erubi'}.h(( bar do  @a << '
'; @a << '   <b>'; @a << #{escape ? '__erubi' : '::Erubi'}.h(( '&' )); @a << '</b>
'; @a << '   ';begin; (__erubi_stack ||= []) << @a; @a = String.new; __erubi_stack.last << #{escape ? '__erubi' : '::Erubi'}.h(( baz do  @a << 'e'; end )).to_s; ensure; @a = __erubi_stack.pop; end; @a << '
'; @a << ' '; end )).to_s; ensure; @a = __erubi_stack.pop; end; @a << '
'; @a << ' </tbody>
</table>
';
@a.to_s
END2
<table>
 <tbody>
  A
   &lt;B&gt;&amp;AMP;&lt;/B&gt;
   CEDCED
 B
 </tbody>
</table>
END3
    end
  end

  [:outvar, :bufvar].each do |var|
    it "should handle :#{var} and :freeze options" do
      @options[var] = "@_out_buf"
      @options[:freeze] = true
      @items = [2]
      i = 0
      check_output(<<END1, <<END2, <<END3){}
<table>
  <% for item in @items %>
  <tr>
    <td><%= i+1 %></td>
    <td><%== item %></td>
  </tr>
  <% end %>
</table>
END1
# frozen_string_literal: true
@_out_buf = String.new; @_out_buf << '<table>
';   for item in @items 
 @_out_buf << '  <tr>
    <td>'; @_out_buf << ( i+1 ).to_s; @_out_buf << '</td>
    <td>'; @_out_buf << ::Erubi.h(( item )); @_out_buf << '</td>
  </tr>
';   end 
 @_out_buf << '</table>
';
@_out_buf.to_s
END2
<table>
  <tr>
    <td>1</td>
    <td>2</td>
  </tr>
</table>
END3
    end
  end

  it "should handle <%% and <%# syntax" do
    @items = [2]
    i = 0
    check_output(<<END1, <<END2, <<END3){}
<table>
<%% for item in @items %>
  <tr>
    <td><%# i+1 %></td>
    <td><%# item %></td>
  </tr>
  <%% end %>
</table>
END1
_buf = String.new; _buf << '<table>
'; _buf << '<% for item in @items %>
'; _buf << '  <tr>
    <td>';; _buf << '</td>
    <td>';; _buf << '</td>
  </tr>
'; _buf << '  <% end %>
'; _buf << '</table>
';
_buf.to_s
END2
<table>
<% for item in @items %>
  <tr>
    <td></td>
    <td></td>
  </tr>
  <% end %>
</table>
END3
  end

  it "should handle :trim => false option" do
    @options[:trim] = false
    @items = [2]
    i = 0
    check_output(<<END1, <<END2, <<END3){}
<table>
  <% for item in @items %>
  <tr>
    <td><%# 
    i+1
    %></td>
    <td><%== item %></td>
  </tr>
  <% end %><%#%>
  <% i %>a
  <% i %>
</table>
END1
_buf = String.new; _buf << '<table>
'; _buf << '  '; for item in @items ; _buf << '
'; _buf << '  <tr>
    <td>';

 _buf << '</td>
    <td>'; _buf << ::Erubi.h(( item )); _buf << '</td>
  </tr>
'; _buf << '  '; end ;
 _buf << '
'; _buf << '  '; i ; _buf << 'a
'; _buf << '  '; i ; _buf << '
'; _buf << '</table>
';
_buf.to_s
END2
<table>
  
  <tr>
    <td></td>
    <td>2</td>
  </tr>
  
  a
  
</table>
END3
  end

  [:escape, :escape_html].each do  |opt|
    it "should handle :#{opt} and :escapefunc options" do
      @options[opt] = true
      @options[:escapefunc] = 'h.call'
      h = proc{|s| s.to_s*2}
      list = ['2']
      check_output(<<END1, <<END2, <<END3){}
<table>
 <tbody>
  <% i = 0
     list.each_with_index do |item, i| %>
  <tr>
   <td><%= i+1 %></td>
   <td><%== item %></td>
  </tr>
 <% end %>
 </tbody>
</table>
<%== i+1 %>
END1
_buf = String.new; _buf << '<table>
 <tbody>
';   i = 0
     list.each_with_index do |item, i| 
 _buf << '  <tr>
   <td>'; _buf << h.call(( i+1 )); _buf << '</td>
   <td>'; _buf << ( item ).to_s; _buf << '</td>
  </tr>
';  end 
 _buf << ' </tbody>
</table>
'; _buf << ( i+1 ).to_s; _buf << '
';
_buf.to_s
END2
<table>
 <tbody>
  <tr>
   <td>11</td>
   <td>2</td>
  </tr>
 </tbody>
</table>
1
END3
    end
  end

  it "should handle :escape option without :escapefunc option" do
    @options[:escape] = true
    list = ['&\'<>"2']
    check_output(<<END1, <<END2, <<END3){}
<table>
 <tbody>
  <% i = 0
     list.each_with_index do |item, i| %>
  <tr>
   <td><%== i+1 %></td>
   <td><%= item %></td>
  </tr>
 <% end %>
 </tbody>
</table>
END1
__erubi = ::Erubi;_buf = String.new; _buf << '<table>
 <tbody>
';   i = 0
     list.each_with_index do |item, i| 
 _buf << '  <tr>
   <td>'; _buf << ( i+1 ).to_s; _buf << '</td>
   <td>'; _buf << __erubi.h(( item )); _buf << '</td>
  </tr>
';  end 
 _buf << ' </tbody>
</table>
';
_buf.to_s
END2
<table>
 <tbody>
  <tr>
   <td>1</td>
   <td>&amp;&#39;&lt;&gt;&quot;2</td>
  </tr>
 </tbody>
</table>
END3
  end

  it "should handle :preamble and :postamble options" do
    @options[:preamble] = '_buf = String.new("1");'
    @options[:postamble] = "_buf[0...18]\n"
    list = ['2']
    check_output(<<END1, <<END2, <<END3){}
<table>
 <tbody>
  <% i = 0
     list.each_with_index do |item, i| %>
  <tr>
   <td><%= i+1 %></td>
   <td><%== item %></td>
  </tr>
 <% end %>
 </tbody>
</table>
<%== i+1 %>
END1
_buf = String.new("1"); _buf << '<table>
 <tbody>
';   i = 0
     list.each_with_index do |item, i| 
 _buf << '  <tr>
   <td>'; _buf << ( i+1 ).to_s; _buf << '</td>
   <td>'; _buf << ::Erubi.h(( item )); _buf << '</td>
  </tr>
';  end 
 _buf << ' </tbody>
</table>
'; _buf << ::Erubi.h(( i+1 )); _buf << '
';
_buf[0...18]
END2
1<table>
 <tbody>
END3
  end

  it "should have working filename accessor" do
    Erubi::Engine.new('', :filename=>'foo.rb').filename.must_equal 'foo.rb'
  end

  it "should have working bufvar accessor" do
    Erubi::Engine.new('', :bufvar=>'foo').bufvar.must_equal 'foo'
    Erubi::Engine.new('', :outvar=>'foo').bufvar.must_equal 'foo'
  end

  it "should return frozen object" do
    Erubi::Engine.new('').frozen?.must_equal true
  end

  it "should have frozen src" do
    Erubi::Engine.new('').src.frozen?.must_equal true
  end

  it "should raise an error if a tag is not handled when a custom regexp is used" do
    proc{Erubi::Engine.new('<%] %>', :regexp =>/<%(={1,2}|\]|-|\#|%)?(.*?)([-=])?%>([ \t]*\r?\n)?/m)}.must_raise ArgumentError
    proc{Erubi::CaptureEndEngine.new('<%] %>', :regexp =>/<%(={1,2}|\]|-|\#|%)?(.*?)([-=])?%>([ \t]*\r?\n)?/m)}.must_raise ArgumentError
  end
end
