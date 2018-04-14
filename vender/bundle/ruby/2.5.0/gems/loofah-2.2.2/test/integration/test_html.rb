require "helper"

class IntegrationTestHtml < Loofah::TestCase
  context "html fragment" do
    context "#to_s" do
      it "not include head tags (like style)" do
        skip "depends on nokogiri version"
        html = Loofah.fragment "<style>foo</style><div>bar</div>"
        assert_equal "<div>bar</div>", html.to_s
      end
    end

    context "#text" do
      it "not include head tags (like style)" do
        skip "depends on nokogiri version"
        html = Loofah.fragment "<style>foo</style><div>bar</div>"
        assert_equal "bar", html.text
      end
    end

    context "#to_text" do
      it "add newlines before and after html4 block elements" do
        html = Loofah.fragment "<div>tweedle<h1>beetle</h1>bottle<span>puddle</span>paddle<div>battle</div>muddle</div>"
        assert_equal "\ntweedle\nbeetle\nbottlepuddlepaddle\nbattle\nmuddle\n", html.to_text
      end

      it "add newlines before and after html5 block elements" do
        html = Loofah.fragment "<div>tweedle<section>beetle</section>bottle<span>puddle</span>paddle<div>battle</div>muddle</div>"
        assert_equal "\ntweedle\nbeetle\nbottlepuddlepaddle\nbattle\nmuddle\n", html.to_text
      end

      it "remove extraneous whitespace" do
        html = Loofah.fragment "<div>tweedle\n\n\t\n\s\nbeetle</div>"
        assert_equal "\ntweedle\n\nbeetle\n", html.to_text
      end
    end

    context 'with an `encoding` arg' do
      it "sets the parent document's encoding to accordingly" do
        html = Loofah.fragment "<style>foo</style><div>bar</div>", 'US-ASCII'
        assert_equal 'US-ASCII', html.document.encoding
      end
    end
  end

  context "html document" do
    context "#text" do
      it "not include head tags (like style)" do
        html = Loofah.document "<style>foo</style><div>bar</div>"
        assert_equal "bar", html.text
      end
    end

    context "#to_text" do
      it "add newlines before and after html4 block elements" do
        html = Loofah.document "<div>tweedle<h1>beetle</h1>bottle<span>puddle</span>paddle<div>battle</div>muddle</div>"
        assert_equal "\ntweedle\nbeetle\nbottlepuddlepaddle\nbattle\nmuddle\n", html.to_text
      end

      it "add newlines before and after html5 block elements" do
        html = Loofah.document "<div>tweedle<section>beetle</section>bottle<span>puddle</span>paddle<div>battle</div>muddle</div>"
        assert_equal "\ntweedle\nbeetle\nbottlepuddlepaddle\nbattle\nmuddle\n", html.to_text
      end

      it "remove extraneous whitespace" do
        html = Loofah.document "<div>tweedle\n\n\t\n\s\nbeetle</div>"
        assert_equal "\ntweedle\n\nbeetle\n", html.to_text
      end
    end
  end
end

