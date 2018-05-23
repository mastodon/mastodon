# frozen_string_literal: true

RSpec.describe HTTP::Headers::Mixin do
  let :dummy_class do
    Class.new do
      include HTTP::Headers::Mixin

      def initialize(headers)
        @headers = headers
      end
    end
  end

  let(:headers) { HTTP::Headers.new }
  let(:dummy)   { dummy_class.new headers }

  describe "#headers" do
    it "returns @headers instance variable" do
      expect(dummy.headers).to be headers
    end
  end

  describe "#[]" do
    it "proxies to headers#[]" do
      expect(headers).to receive(:[]).with(:accept)
      dummy[:accept]
    end
  end

  describe "#[]=" do
    it "proxies to headers#[]" do
      expect(headers).to receive(:[]=).with(:accept, "text/plain")
      dummy[:accept] = "text/plain"
    end
  end
end
