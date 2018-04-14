require "helper"

class UnitTestHelpers < Loofah::TestCase

  HTML_STRING = "<div>omgwtfbbq</div>"

  describe "Helpers" do
    context ".strip_tags" do
      it "invoke Loofah.fragment.text" do
        mock_doc = Object.new
        mock(Loofah).fragment(HTML_STRING) { mock_doc }
        mock(mock_doc).text

        Loofah::Helpers.strip_tags HTML_STRING
      end
    end

    context ".sanitize" do
      it "invoke Loofah.scrub_fragment(:strip).to_s" do
        mock_doc = Object.new
        mock_node = Object.new
        mock(Loofah).fragment(HTML_STRING) { mock_doc }
        mock(mock_doc).scrub!(:strip) { mock_doc }
        mock(mock_doc).xpath("./form") { [mock_node] }
        mock(mock_node).remove
        mock(mock_doc).to_s

        Loofah::Helpers.sanitize HTML_STRING
      end
    end

    context ".sanitize_css" do
      it "invokes HTML5lib's css scrubber" do
        mock(Loofah::HTML5::Scrub).scrub_css("foobar")
        Loofah::Helpers.sanitize_css("foobar")
      end
    end

    describe "ActionView" do
      describe "FullSanitizer#sanitize" do
        it "calls .strip_tags" do
          mock(Loofah::Helpers).strip_tags("foobar")
          Loofah::Helpers::ActionView::FullSanitizer.new.sanitize "foobar"
        end
      end

      describe "WhiteListSanitizer#sanitize" do
        it "calls .sanitize" do
          mock(Loofah::Helpers).sanitize("foobar")
          Loofah::Helpers::ActionView::WhiteListSanitizer.new.sanitize "foobar"
        end
      end

      describe "WhiteListSanitizer#sanitize_css" do
        it "calls .sanitize_css" do
          mock(Loofah::Helpers).sanitize_css("foobar")
          Loofah::Helpers::ActionView::WhiteListSanitizer.new.sanitize_css "foobar"
        end
      end
    end
  end
end
