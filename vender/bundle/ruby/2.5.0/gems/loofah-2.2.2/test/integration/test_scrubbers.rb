require "helper"

class IntegrationTestScrubbers < Loofah::TestCase

  INVALID_FRAGMENT = "<invalid>foo<p>bar</p>bazz</invalid><div>quux</div>"
  INVALID_ESCAPED  = "&lt;invalid&gt;foo&lt;p&gt;bar&lt;/p&gt;bazz&lt;/invalid&gt;<div>quux</div>"
  INVALID_PRUNED   = "<div>quux</div>"
  INVALID_STRIPPED = "foo<p>bar</p>bazz<div>quux</div>"

  WHITEWASH_FRAGMENT = "<o:div>no</o:div><div id='no'>foo</div><invalid>bar</invalid><!--[if gts mso9]><div>microsofty stuff</div><![endif]-->"
  WHITEWASH_RESULT   = "<div>foo</div>"

  NOFOLLOW_FRAGMENT = '<a href="http://www.example.com/">Click here</a>'
  NOFOLLOW_RESULT   = '<a href="http://www.example.com/" rel="nofollow">Click here</a>'

  NOFOLLOW_WITH_REL_FRAGMENT = '<a href="http://www.example.com/" rel="noopener">Click here</a>'
  NOFOLLOW_WITH_REL_RESULT   = '<a href="http://www.example.com/" rel="noopener nofollow">Click here</a>'

  NOOPENER_FRAGMENT = '<a href="http://www.example.com/">Click here</a>'
  NOOPENER_RESULT   = '<a href="http://www.example.com/" rel="noopener">Click here</a>'

  NOOPENER_WITH_REL_FRAGMENT = '<a href="http://www.example.com/" rel="nofollow">Click here</a>'
  NOOPENER_WITH_REL_RESULT   = '<a href="http://www.example.com/" rel="nofollow noopener">Click here</a>'

  UNPRINTABLE_FRAGMENT = "<b>Lo\u2029ofah ro\u2028cks!</b><script>x\u2028y</script>"
  UNPRINTABLE_RESULT = "<b>Loofah rocks!</b><script>xy</script>"

  ENTITY_FRAGMENT   = "<p>this is &lt; that &quot;&amp;&quot; the other &gt; boo&apos;ya</p><div>w00t</div>"
  ENTITY_TEXT       = %Q(this is < that "&" the other > boo\'yaw00t)

  ENTITY_HACK_ATTACK            = "<div><div>Hack attack!</div><div>&lt;script&gt;alert('evil')&lt;/script&gt;</div></div>"
  ENTITY_HACK_ATTACK_TEXT_SCRUB = "Hack attack!&lt;script&gt;alert('evil')&lt;/script&gt;"
  ENTITY_HACK_ATTACK_TEXT_SCRUB_UNESC = "Hack attack!<script>alert('evil')</script>"

  context "Document" do
    context "#scrub!" do
      context ":escape" do
        it "escape bad tags" do
          doc = Loofah::HTML::Document.parse "<html><body>#{INVALID_FRAGMENT}</body></html>"
          result = doc.scrub! :escape

          assert_equal INVALID_ESCAPED, doc.xpath('/html/body').inner_html
          assert_equal doc, result
        end
      end

      context ":prune" do
        it "prune bad tags" do
          doc = Loofah::HTML::Document.parse "<html><body>#{INVALID_FRAGMENT}</body></html>"
          result = doc.scrub! :prune

          assert_equal INVALID_PRUNED, doc.xpath('/html/body').inner_html
          assert_equal doc, result
        end
      end

      context ":strip" do
        it "strip bad tags" do
          doc = Loofah::HTML::Document.parse "<html><body>#{INVALID_FRAGMENT}</body></html>"
          result = doc.scrub! :strip

          assert_equal INVALID_STRIPPED, doc.xpath('/html/body').inner_html
          assert_equal doc, result
        end
      end

      context ":whitewash" do
        it "whitewash the markup" do
          doc = Loofah::HTML::Document.parse "<html><body>#{WHITEWASH_FRAGMENT}</body></html>"
          result = doc.scrub! :whitewash

          assert_equal WHITEWASH_RESULT, doc.xpath('/html/body').inner_html
          assert_equal doc, result
        end
      end

      context ":nofollow" do
        it "add a 'nofollow' attribute to hyperlinks" do
          doc = Loofah::HTML::Document.parse "<html><body>#{NOFOLLOW_FRAGMENT}</body></html>"
          result = doc.scrub! :nofollow

          assert_equal NOFOLLOW_RESULT, doc.xpath('/html/body').inner_html
          assert_equal doc, result
        end
      end

      context ":unprintable" do
        it "removes unprintable unicode characters" do
          doc = Loofah::HTML::Document.parse "<html><body>#{UNPRINTABLE_FRAGMENT}</body></html>"
          result = doc.scrub! :unprintable

          assert_equal UNPRINTABLE_RESULT, doc.xpath("/html/body").inner_html
          assert_equal doc, result
        end
      end
    end

    context "#scrub_document" do
      it "be a shortcut for parse-and-scrub" do
        mock_doc = Object.new
        mock(Loofah).document(:string_or_io) { mock_doc }
        mock(mock_doc).scrub!(:method)

        Loofah.scrub_document(:string_or_io, :method)
      end
    end

    context "#text" do
      it "leave behind only inner text with html entities still escaped" do
        doc = Loofah::HTML::Document.parse "<html><body>#{ENTITY_HACK_ATTACK}</body></html>"
        result = doc.text

        assert_equal ENTITY_HACK_ATTACK_TEXT_SCRUB, result
      end

      context "with encode_special_chars => false" do
        it "leave behind only inner text with html entities unescaped" do
          doc = Loofah::HTML::Document.parse "<html><body>#{ENTITY_HACK_ATTACK}</body></html>"
          result = doc.text(:encode_special_chars => false)

          assert_equal ENTITY_HACK_ATTACK_TEXT_SCRUB_UNESC, result
        end
      end

      context "with encode_special_chars => true" do
        it "leave behind only inner text with html entities still escaped" do
          doc = Loofah::HTML::Document.parse "<html><body>#{ENTITY_HACK_ATTACK}</body></html>"
          result = doc.text(:encode_special_chars => true)

          assert_equal ENTITY_HACK_ATTACK_TEXT_SCRUB, result
        end
      end
    end

    context "#to_s" do
      it "generate HTML" do
        doc = Loofah.scrub_document "<html><head><title>quux</title></head><body><div>foo</div></body></html>", :prune
        refute_nil doc.xpath("/html").first
        refute_nil doc.xpath("/html/head").first
        refute_nil doc.xpath("/html/body").first

        string = doc.to_s
        assert_match %r/<!DOCTYPE/, string
        assert_match %r/<html>/, string
        assert_match %r/<head>/, string
        assert_match %r/<body>/, string
      end
    end

    context "#serialize" do
      it "generate HTML" do
        doc = Loofah.scrub_document "<html><head><title>quux</title></head><body><div>foo</div></body></html>", :prune
        refute_nil doc.xpath("/html").first
        refute_nil doc.xpath("/html/head").first
        refute_nil doc.xpath("/html/body").first

        string = doc.serialize
        assert_match %r/<!DOCTYPE/, string
        assert_match %r/<html>/, string
        assert_match %r/<head>/, string
        assert_match %r/<body>/, string
      end
    end

    context "Node" do
      context "#scrub!" do
        it "only scrub subtree" do
          xml = Loofah.document <<-EOHTML
           <html><body>
             <div class='scrub'>
               <script>I should be removed</script>
             </div>
             <div class='noscrub'>
               <script>I should remain</script>
             </div>
           </body></html>
          EOHTML
          node = xml.at_css "div.scrub"
          node.scrub!(:prune)
          assert_match %r/I should remain/,     xml.to_s
          refute_match %r/I should be removed/, xml.to_s
        end
      end
    end

    context "NodeSet" do
      context "#scrub!" do
        it "only scrub subtrees" do
          xml = Loofah.document <<-EOHTML
            <html><body>
              <div class='scrub'>
                <script>I should be removed</script>
              </div>
              <div class='noscrub'>
                <script>I should remain</script>
              </div>
              <div class='scrub'>
                <script>I should also be removed</script>
              </div>
            </body></html>
          EOHTML
          node_set = xml.css "div.scrub"
          assert_equal 2, node_set.length
          node_set.scrub!(:prune)
          assert_match %r/I should remain/,          xml.to_s
          refute_match %r/I should be removed/,      xml.to_s
          refute_match %r/I should also be removed/, xml.to_s
        end
      end
    end
  end

  context "DocumentFragment" do
    context "#scrub!" do
      context ":escape" do
        it "escape bad tags" do
          doc = Loofah::HTML::DocumentFragment.parse "<div>#{INVALID_FRAGMENT}</div>"
          result = doc.scrub! :escape

          assert_equal INVALID_ESCAPED, doc.xpath("./div").inner_html
          assert_equal doc, result
        end
      end

      context ":prune" do
        it "prune bad tags" do
          doc = Loofah::HTML::DocumentFragment.parse "<div>#{INVALID_FRAGMENT}</div>"
          result = doc.scrub! :prune

          assert_equal INVALID_PRUNED, doc.xpath("./div").inner_html
          assert_equal doc, result
        end
      end

      context ":strip" do
        it "strip bad tags" do
          doc = Loofah::HTML::DocumentFragment.parse "<div>#{INVALID_FRAGMENT}</div>"
          result = doc.scrub! :strip

          assert_equal INVALID_STRIPPED, doc.xpath("./div").inner_html
          assert_equal doc, result
        end
      end

      context ":whitewash" do
        it "whitewash the markup" do
          doc = Loofah::HTML::DocumentFragment.parse "<div>#{WHITEWASH_FRAGMENT}</div>"
          result = doc.scrub! :whitewash

          assert_equal WHITEWASH_RESULT, doc.xpath("./div").inner_html
          assert_equal doc, result
        end
      end

      context ":nofollow" do

        context "for a hyperlink that does not have a rel attribute" do
          it "add a 'nofollow' attribute to hyperlinks" do
            doc = Loofah::HTML::DocumentFragment.parse "<div>#{NOFOLLOW_FRAGMENT}</div>"
            result = doc.scrub! :nofollow

            assert_equal NOFOLLOW_RESULT, doc.xpath("./div").inner_html
            assert_equal doc, result
          end
        end

        context "for a hyperlink that does have a rel attribute" do
          it "appends nofollow to rel attribute" do
              doc = Loofah::HTML::DocumentFragment.parse "<div>#{NOFOLLOW_WITH_REL_FRAGMENT}</div>"
              result = doc.scrub! :nofollow

              assert_equal NOFOLLOW_WITH_REL_RESULT, doc.xpath("./div").inner_html
              assert_equal doc, result
          end
        end


      end

      context ":noopener" do
        context "for a hyperlink without a 'rel' attribute" do
          it "add a 'noopener' attribute to hyperlinks" do
            doc = Loofah::HTML::DocumentFragment.parse "<div>#{NOOPENER_FRAGMENT}</div>"
            result = doc.scrub! :noopener

            assert_equal NOOPENER_RESULT, doc.xpath("./div").inner_html
            assert_equal doc, result
          end
        end

        context "for a hyperlink that does have a rel attribute" do
          it "appends 'noopener' to 'rel' attribute" do
            doc = Loofah::HTML::DocumentFragment.parse "<div>#{NOOPENER_WITH_REL_FRAGMENT}</div>"
            result = doc.scrub! :noopener

            assert_equal NOOPENER_WITH_REL_RESULT, doc.xpath("./div").inner_html
            assert_equal doc, result
          end
        end
      end

      context ":unprintable" do
        it "removes unprintable unicode characters" do
          doc = Loofah::HTML::DocumentFragment.parse "<div>#{UNPRINTABLE_FRAGMENT}</div>"
          result = doc.scrub! :unprintable

          assert_equal UNPRINTABLE_RESULT, doc.xpath("./div").inner_html
          assert_equal doc, result
        end
      end
    end

    context "#scrub_fragment" do
      it "be a shortcut for parse-and-scrub" do
        mock_doc = Object.new
        mock(Loofah).fragment(:string_or_io) { mock_doc }
        mock(mock_doc).scrub!(:method)

        Loofah.scrub_fragment(:string_or_io, :method)
      end
    end

    context "#text" do
      it "leave behind only inner text with html entities still escaped" do
        doc = Loofah::HTML::DocumentFragment.parse "<div>#{ENTITY_HACK_ATTACK}</div>"
        result = doc.text

        assert_equal ENTITY_HACK_ATTACK_TEXT_SCRUB, result
      end

      context "with encode_special_chars => false" do
        it "leave behind only inner text with html entities unescaped" do
          doc = Loofah::HTML::DocumentFragment.parse "<div>#{ENTITY_HACK_ATTACK}</div>"
          result = doc.text(:encode_special_chars => false)

          assert_equal ENTITY_HACK_ATTACK_TEXT_SCRUB_UNESC, result
        end
      end

      context "with encode_special_chars => true" do
        it "leave behind only inner text with html entities still escaped" do
          doc = Loofah::HTML::DocumentFragment.parse "<div>#{ENTITY_HACK_ATTACK}</div>"
          result = doc.text(:encode_special_chars => true)

          assert_equal ENTITY_HACK_ATTACK_TEXT_SCRUB, result
        end
      end
    end

    context "#to_s" do
      it "not remove entities" do
        string = Loofah.scrub_fragment(ENTITY_FRAGMENT, :prune).to_s
        assert_match %r/this is &lt;/, string
      end
    end

    context "Node" do
      context "#scrub!" do
        it "only scrub subtree" do
          xml = Loofah.fragment <<-EOHTML
            <div class='scrub'>
              <script>I should be removed</script>
            </div>
            <div class='noscrub'>
              <script>I should remain</script>
            </div>
          EOHTML
          node = xml.at_css "div.scrub"
          node.scrub!(:prune)
          assert_match %r(I should remain),     xml.to_s
          refute_match %r(I should be removed), xml.to_s
        end
      end
    end

    context "NodeSet" do
      context "#scrub!" do
        it "only scrub subtrees" do
          xml = Loofah.fragment <<-EOHTML
            <div class='scrub'>
              <script>I should be removed</script>
            </div>
            <div class='noscrub'>
              <script>I should remain</script>
            </div>
            <div class='scrub'>
              <script>I should also be removed</script>
            </div>
          EOHTML
          node_set = xml.css "div.scrub"
          assert_equal 2, node_set.length
          node_set.scrub!(:prune)
          assert_match %r/I should remain/,          xml.to_s
          refute_match %r/I should be removed/,      xml.to_s
          refute_match %r/I should also be removed/, xml.to_s
        end
      end
    end
  end
end
