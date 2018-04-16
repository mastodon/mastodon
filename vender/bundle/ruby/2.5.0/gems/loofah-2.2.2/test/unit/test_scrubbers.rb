require "helper"

class UnitTestScrubbers < Loofah::TestCase
  [ Loofah::HTML::Document, Loofah::HTML::DocumentFragment ].each do |klass|
    context klass do
      context "bad scrub method" do
        it "raise a ScrubberNotFound exception" do
          doc = klass.parse "<p>foo</p>"
          assert_raises(Loofah::ScrubberNotFound) { doc.scrub! :frippery }
        end
      end
    end
  end
end
