require 'helper'
require 'tilt/erubis'

describe Temple::ERB::Engine do
  it 'should compile erb' do
    src = %q{
%% hi
= hello
<% 3.times do |n| %>
* <%= n %>
<% end %>
}

    erb(src).should.equal erubis(src)
  end

  it 'should recognize comments' do
    src = %q{
hello
  <%# comment -- ignored -- useful in testing %>
world}

    erb(src).should.equal erubis(src)
  end

  it 'should recognize <%% and %%>' do
    src = %q{
<%%
<% if true %>
  %%>
<% end %>
}

    erb(src).should.equal "\n<%\n  %>\n"
  end

  it 'should escape automatically' do
    src = '<%= "<" %>'
    ans = '&lt;'
    erb(src).should.equal ans
  end

  it 'should support == to disable automatic escape' do
    src = '<%== "<" %>'
    ans = '<'
    erb(src).should.equal ans
  end

  it 'should support trim mode' do
    src = %q{
%% hi
= hello
<% 3.times do |n| %>
* <%= n %>
<% end %>
}

    erb(src, trim: true).should.equal erubis(src, trim: true)
    erb(src, trim: false).should.equal erubis(src, trim: false)
  end
end
