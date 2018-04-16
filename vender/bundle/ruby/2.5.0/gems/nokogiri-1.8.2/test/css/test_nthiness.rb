require "helper"

module Nokogiri
  module CSS
    class TestNthiness < Nokogiri::TestCase
      def setup
        super
        doc = <<EOF
<html>
<table>
  <tr><td>row1 </td></tr>
  <tr><td>row2 </td></tr>
  <tr><td>row3 </td></tr>
  <tr><td>row4 </td></tr>
  <tr><td>row5 </td></tr>
  <tr><td>row6 </td></tr>
  <tr><td>row7 </td></tr>
  <tr><td>row8 </td></tr>
  <tr><td>row9 </td></tr>
  <tr><td>row10 </td></tr>
  <tr><td>row11 </td></tr>
  <tr><td>row12 </td></tr>
  <tr><td>row13 </td></tr>
  <tr><td>row14 </td></tr>
</table>
<div>
  <b>bold1 </b>
  <i>italic1 </i>
  <b class="a">bold2 </b>
  <em class="a">emphasis1 </em>
  <i>italic2 </i>
  <p>para1 </p>
  <b class="a">bold3 </b>
</div>
<div>
  <i class="b">italic3 </i>
  <em>emphasis2 </em>
  <i class="b">italic4 </i>
  <em>emphasis3 </em>
  <i class="c">italic5 </i>
  <span><i class="b">italic6 </i></span>  
  <i>italic7 </i>
</div>
<div>
  <p>para2 </p>
  <p>para3 </p>
</div>
<div>
  <p>para4 </p>
</div>

<div>
  <h2></h2>
  <h1 class='c'>header1 </h1>
  <h2></h2>
</div>
<div>
  <h1 class='c'>header2 </h1>
  <h1 class='c'>header3 </h1>
</div>
<div>
  <h1 class='c'>header4</h1>
</div>
  
<p class='empty'></p>
<p class='not-empty'><b></b></p>
</html>
EOF
        @parser = Nokogiri.HTML doc
      end


      def test_even
        assert_result_rows [2,4,6,8,10,12,14], @parser.search("table/tr:nth(even)")
      end

      def test_odd
        assert_result_rows [1,3,5,7,9,11,13], @parser.search("table/tr:nth(odd)")
      end

      def test_n
        assert_result_rows((1..14).to_a, @parser.search("table/tr:nth(n)"))
      end

      def test_2n
        assert_equal @parser.search("table/tr:nth(even)").inner_text, @parser.search("table/tr:nth(2n)").inner_text
      end

      def test_2np1
        assert_equal @parser.search("table/tr:nth(odd)").inner_text, @parser.search("table/tr:nth(2n+1)").inner_text
      end

      def test_4np3
        assert_result_rows [3,7,11], @parser.search("table/tr:nth(4n+3)")
      end

      def test_3np4
        assert_result_rows [4,7,10,13], @parser.search("table/tr:nth(3n+4)")
      end

      def test_mnp3
        assert_result_rows [1,2,3], @parser.search("table/tr:nth(-n+3)")
      end

      def test_4nm1
        assert_result_rows [3,7,11], @parser.search("table/tr:nth(4n-1)")
      end

      def test_np3
        assert_result_rows [3,4,5,6,7,8,9,10,11,12,13,14], @parser.search("table/tr:nth(n+3)")
      end

      def test_first
        assert_result_rows [1], @parser.search("table/tr:first")
        assert_result_rows [1], @parser.search("table/tr:first()")
      end

      def test_last
        assert_result_rows [14], @parser.search("table/tr:last")
        assert_result_rows [14], @parser.search("table/tr:last()")
      end

      def test_first_child
        assert_result_rows [1], @parser.search("div/b:first-child"), "bold"
        assert_result_rows [1], @parser.search("table/tr:first-child")
        assert_result_rows [2,4],  @parser.search("div/h1.c:first-child"), "header"
      end

      def test_last_child
        assert_result_rows [3], @parser.search("div/b:last-child"), "bold"
        assert_result_rows [14], @parser.search("table/tr:last-child")
        assert_result_rows [3,4], @parser.search("div/h1.c:last-child"), "header"
      end
      
      def test_nth_child
        assert_result_rows [2], @parser.search("div/b:nth-child(3)"), "bold"
        assert_result_rows [5], @parser.search("table/tr:nth-child(5)")
        assert_result_rows [1,3], @parser.search("div/h1.c:nth-child(2)"), "header"
        assert_result_rows [3,4], @parser.search("div/i.b:nth-child(2n+1)"), "italic"
      end

      def test_first_of_type
        assert_result_rows [1], @parser.search("table/tr:first-of-type")
        assert_result_rows [1], @parser.search("div/b:first-of-type"), "bold"
        assert_result_rows [2], @parser.search("div/b.a:first-of-type"), "bold"
        assert_result_rows [3], @parser.search("div/i.b:first-of-type"), "italic"
      end

      def test_last_of_type
        assert_result_rows [14], @parser.search("table/tr:last-of-type")
        assert_result_rows [3], @parser.search("div/b:last-of-type"), "bold"
        assert_result_rows [2,7], @parser.search("div/i:last-of-type"), "italic"
        assert_result_rows [2,6,7], @parser.search("div i:last-of-type"), "italic"
        assert_result_rows [4], @parser.search("div/i.b:last-of-type"), "italic"
      end
      
      def test_nth_of_type
        assert_result_rows [1], @parser.search("div/b:nth-of-type(1)"), "bold"
        assert_result_rows [2], @parser.search("div/b:nth-of-type(2)"), "bold"
        assert_result_rows [2], @parser.search("div/.a:nth-of-type(1)"), "bold"
        assert_result_rows [2,4,7], @parser.search("div i:nth-of-type(2n)"), "italic"
        assert_result_rows [1,3,5,6], @parser.search("div i:nth-of-type(2n+1)"), "italic"
        assert_result_rows [1], @parser.search("div .a:nth-of-type(2n)"), "emphasis"
        assert_result_rows [2,3], @parser.search("div .a:nth-of-type(2n+1)"), "bold"
      end
      
      def test_nth_last_of_type
        assert_result_rows [14], @parser.search("table/tr:nth-last-of-type(1)")
        assert_result_rows [12], @parser.search("table/tr:nth-last-of-type(3)")
        assert_result_rows [2,6,7], @parser.search("div i:nth-last-of-type(1)"), "italic"
        assert_result_rows [1,5], @parser.search("div i:nth-last-of-type(2)"), "italic"        
        assert_result_rows [4], @parser.search("div/i.b:nth-last-of-type(1)"), "italic"
        assert_result_rows [3], @parser.search("div/i.b:nth-last-of-type(2)"), "italic"
      end

      def test_only_of_type
        assert_result_rows [1,4], @parser.search("div/p:only-of-type"), "para"
        assert_result_rows [5], @parser.search("div/i.c:only-of-type"), "italic"
      end

      def test_only_child
        assert_result_rows [4], @parser.search("div/p:only-child"), "para"
        assert_result_rows [4], @parser.search("div/h1.c:only-child"), "header"
      end

      def test_empty
        result = @parser.search("p:empty")
        assert_equal 1, result.size, "unexpected number of rows returned: '#{result.inner_text}'"
        assert_equal 'empty', result.first['class']
      end

      def test_parent
        result = @parser.search("p:parent")
        assert_equal 5, result.size
        0.upto(3) do |j|
          assert_equal "para#{j+1} ", result[j].inner_text
        end
        assert_equal "not-empty", result[4]['class']
      end

      def test_siblings
        doc = <<-EOF
<html><body><div>
<p id="1">p1 </p>
<p id="2">p2 </p>
<p id="3">p3 </p>
<p id="4">p4 </p>
<p id="5">p5 </p>
EOF
        parser = Nokogiri.HTML doc
        assert_equal 2, parser.search("#3 ~ p").size
        assert_equal "p4 p5 ", parser.search("#3 ~ p").inner_text
        assert_equal 0, parser.search("#5 ~ p").size

        assert_equal 1, parser.search("#3 + p").size
        assert_equal "p4 ", parser.search("#3 + p").inner_text
        assert_equal 0, parser.search("#5 + p").size
      end

      def assert_result_rows intarray, result, word="row"
        assert_equal intarray.size, result.size, "unexpected number of rows returned: '#{result.inner_text}'"
        assert_equal intarray.map{|j| "#{word}#{j}"}.join(' '), result.inner_text.strip, result.inner_text
      end
    end
  end
end
