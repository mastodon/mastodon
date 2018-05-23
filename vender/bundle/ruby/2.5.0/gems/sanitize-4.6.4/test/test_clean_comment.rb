# encoding: utf-8
require_relative 'common'

describe 'Sanitize::Transformers::CleanComment' do
  make_my_diffs_pretty!
  parallelize_me!

  describe 'when :allow_comments is false' do
    before do
      @s = Sanitize.new(:allow_comments => false, :elements => ['div'])
    end

    it 'should remove comments' do
      @s.fragment('foo <!-- comment --> bar').must_equal 'foo  bar'
      @s.fragment('foo <!-- ').must_equal 'foo '
      @s.fragment('foo <!-- - -> bar').must_equal 'foo '
      @s.fragment("foo <!--\n\n\n\n-->bar").must_equal 'foo bar'
      @s.fragment("foo <!-- <!-- <!-- --> --> -->bar").must_equal 'foo  --&gt; --&gt;bar'
      @s.fragment("foo <div <!-- comment -->>bar</div>").must_equal 'foo <div>&gt;bar</div>'

      # Special case: the comment markup is inside a <script>, which makes it
      # text content and not an actual HTML comment.
      @s.fragment("<script><!-- comment --></script>").must_equal '&lt;!-- comment --&gt;'

      Sanitize.fragment("<script><!-- comment --></script>", :allow_comments => false, :elements => ['script'])
        .must_equal '<script><!-- comment --></script>'
    end
  end

  describe 'when :allow_comments is true' do
    before do
      @s = Sanitize.new(:allow_comments => true, :elements => ['div'])
    end

    it 'should allow comments' do
      @s.fragment('foo <!-- comment --> bar').must_equal 'foo <!-- comment --> bar'
      @s.fragment('foo <!-- ').must_equal 'foo <!-- -->'
      @s.fragment('foo <!-- - -> bar').must_equal 'foo <!-- - -> bar-->'
      @s.fragment("foo <!--\n\n\n\n-->bar").must_equal "foo <!--\n\n\n\n-->bar"
      @s.fragment("foo <!-- <!-- <!-- --> --> -->bar").must_equal 'foo <!-- <!-- <!-- --> --&gt; --&gt;bar'
      @s.fragment("foo <div <!-- comment -->>bar</div>").must_equal 'foo <div>&gt;bar</div>'

      # Special case: the comment markup is inside a <script>, which makes it
      # text content and not an actual HTML comment.
      @s.fragment("<script><!-- comment --></script>").must_equal '&lt;!-- comment --&gt;'

      Sanitize.fragment("<script><!-- comment --></script>", :allow_comments => true, :elements => ['script'])
        .must_equal '<script><!-- comment --></script>'
    end
  end
end
