RSpec.shared_examples "an OEmbed::Proviers instance" do |expected_valid_urls, expected_invalid_urls|
  expected_valid_urls.each do |valid_url|
    context "given the valid URL #{valid_url}" do
      describe ".include?" do
        it "should be true" do
          expect(provider_class.include?(valid_url)).to be_truthy
        end
      end

      describe ".get" do
        it "should return a response" do
          response = nil
          expect {
            response = provider_class.get(valid_url)
          }.to_not raise_error
          expect(response).to be_a(OEmbed::Response)
        end
      end
    end
  end

  expected_invalid_urls.each do |invalid_url|
    context "given the invalid URL #{invalid_url}" do
      describe ".include?" do
        it "should be false" do
          expect(provider_class.include?(invalid_url)).to be_falsey
        end
      end

      describe ".get" do
        it "should not find a response" do
          expect {
            provider_class.get(invalid_url)
          }.to raise_error(OEmbed::NotFound)
        end
      end
    end
  end
end
