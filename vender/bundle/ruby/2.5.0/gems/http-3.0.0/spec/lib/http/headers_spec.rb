# frozen_string_literal: true

RSpec.describe HTTP::Headers do
  subject(:headers) { described_class.new }

  it "is Enumerable" do
    expect(headers).to be_an Enumerable
  end

  describe "#set" do
    it "sets header value" do
      headers.set "Accept", "application/json"
      expect(headers["Accept"]).to eq "application/json"
    end

    it "normalizes header name" do
      headers.set :content_type, "application/json"
      expect(headers["Content-Type"]).to eq "application/json"
    end

    it "overwrites previous value" do
      headers.set :set_cookie, "hoo=ray"
      headers.set :set_cookie, "woo=hoo"
      expect(headers["Set-Cookie"]).to eq "woo=hoo"
    end

    it "allows set multiple values" do
      headers.set :set_cookie, "hoo=ray"
      headers.set :set_cookie, %w[hoo=ray woo=hoo]
      expect(headers["Set-Cookie"]).to eq %w[hoo=ray woo=hoo]
    end

    it "fails with empty header name" do
      expect { headers.set "", "foo bar" }.
        to raise_error HTTP::HeaderError
    end

    it "fails with invalid header name" do
      expect { headers.set "foo bar", "baz" }.
        to raise_error HTTP::HeaderError
    end
  end

  describe "#[]=" do
    it "sets header value" do
      headers["Accept"] = "application/json"
      expect(headers["Accept"]).to eq "application/json"
    end

    it "normalizes header name" do
      headers[:content_type] = "application/json"
      expect(headers["Content-Type"]).to eq "application/json"
    end

    it "overwrites previous value" do
      headers[:set_cookie] = "hoo=ray"
      headers[:set_cookie] = "woo=hoo"
      expect(headers["Set-Cookie"]).to eq "woo=hoo"
    end

    it "allows set multiple values" do
      headers[:set_cookie] = "hoo=ray"
      headers[:set_cookie] = %w[hoo=ray woo=hoo]
      expect(headers["Set-Cookie"]).to eq %w[hoo=ray woo=hoo]
    end
  end

  describe "#delete" do
    before { headers.set "Content-Type", "application/json" }

    it "removes given header" do
      headers.delete "Content-Type"
      expect(headers["Content-Type"]).to be_nil
    end

    it "normalizes header name" do
      headers.delete :content_type
      expect(headers["Content-Type"]).to be_nil
    end

    it "fails with empty header name" do
      expect { headers.delete "" }.
        to raise_error HTTP::HeaderError
    end

    it "fails with invalid header name" do
      expect { headers.delete "foo bar" }.
        to raise_error HTTP::HeaderError
    end
  end

  describe "#add" do
    it "sets header value" do
      headers.add "Accept", "application/json"
      expect(headers["Accept"]).to eq "application/json"
    end

    it "normalizes header name" do
      headers.add :content_type, "application/json"
      expect(headers["Content-Type"]).to eq "application/json"
    end

    it "appends new value if header exists" do
      headers.add :set_cookie, "hoo=ray"
      headers.add :set_cookie, "woo=hoo"
      expect(headers["Set-Cookie"]).to eq %w[hoo=ray woo=hoo]
    end

    it "allows append multiple values" do
      headers.add :set_cookie, "hoo=ray"
      headers.add :set_cookie, %w[woo=hoo yup=pie]
      expect(headers["Set-Cookie"]).to eq %w[hoo=ray woo=hoo yup=pie]
    end

    it "fails with empty header name" do
      expect { headers.add("", "foobar") }.
        to raise_error HTTP::HeaderError
    end

    it "fails with invalid header name" do
      expect { headers.add "foo bar", "baz" }.
        to raise_error HTTP::HeaderError
    end
  end

  describe "#get" do
    before { headers.set("Content-Type", "application/json") }

    it "returns array of associated values" do
      expect(headers.get("Content-Type")).to eq %w[application/json]
    end

    it "normalizes header name" do
      expect(headers.get(:content_type)).to eq %w[application/json]
    end

    context "when header does not exists" do
      it "returns empty array" do
        expect(headers.get(:accept)).to eq []
      end
    end

    it "fails with empty header name" do
      expect { headers.get("") }.
        to raise_error HTTP::HeaderError
    end

    it "fails with invalid header name" do
      expect { headers.get("foo bar") }.
        to raise_error HTTP::HeaderError
    end
  end

  describe "#[]" do
    context "when header does not exists" do
      it "returns nil" do
        expect(headers[:accept]).to be_nil
      end
    end

    context "when header has a single value" do
      before { headers.set "Content-Type", "application/json" }

      it "normalizes header name" do
        expect(headers[:content_type]).to_not be_nil
      end

      it "returns it returns a single value" do
        expect(headers[:content_type]).to eq "application/json"
      end
    end

    context "when header has a multiple values" do
      before do
        headers.add :set_cookie, "hoo=ray"
        headers.add :set_cookie, "woo=hoo"
      end

      it "normalizes header name" do
        expect(headers[:set_cookie]).to_not be_nil
      end

      it "returns array of associated values" do
        expect(headers[:set_cookie]).to eq %w[hoo=ray woo=hoo]
      end
    end
  end

  describe "#include?" do
    before do
      headers.add :content_type, "application/json"
      headers.add :set_cookie,   "hoo=ray"
      headers.add :set_cookie,   "woo=hoo"
    end

    it "tells whenever given headers is set or not" do
      expect(headers.include?("Content-Type")).to be true
      expect(headers.include?("Set-Cookie")).to be true
      expect(headers.include?("Accept")).to be false
    end

    it "normalizes given header name" do
      expect(headers.include?(:content_type)).to be true
      expect(headers.include?(:set_cookie)).to be true
      expect(headers.include?(:accept)).to be false
    end
  end

  describe "#to_h" do
    before do
      headers.add :content_type, "application/json"
      headers.add :set_cookie,   "hoo=ray"
      headers.add :set_cookie,   "woo=hoo"
    end

    it "returns a Hash" do
      expect(headers.to_h).to be_a ::Hash
    end

    it "returns Hash with normalized keys" do
      expect(headers.to_h.keys).to match_array %w[Content-Type Set-Cookie]
    end

    context "for a header with single value" do
      it "provides a value as is" do
        expect(headers.to_h["Content-Type"]).to eq "application/json"
      end
    end

    context "for a header with multiple values" do
      it "provides an array of values" do
        expect(headers.to_h["Set-Cookie"]).to eq %w[hoo=ray woo=hoo]
      end
    end
  end

  describe "#to_a" do
    before do
      headers.add :content_type, "application/json"
      headers.add :set_cookie,   "hoo=ray"
      headers.add :set_cookie,   "woo=hoo"
    end

    it "returns an Array" do
      expect(headers.to_a).to be_a Array
    end

    it "returns Array of key/value pairs with normalized keys" do
      expect(headers.to_a).to eq [
        %w[Content-Type application/json],
        %w[Set-Cookie hoo=ray],
        %w[Set-Cookie woo=hoo]
      ]
    end
  end

  describe "#inspect" do
    before  { headers.set :set_cookie, %w[hoo=ray woo=hoo] }
    subject { headers.inspect }

    it { is_expected.to eq '#<HTTP::Headers {"Set-Cookie"=>["hoo=ray", "woo=hoo"]}>' }
  end

  describe "#keys" do
    before do
      headers.add :content_type, "application/json"
      headers.add :set_cookie,   "hoo=ray"
      headers.add :set_cookie,   "woo=hoo"
    end

    it "returns uniq keys only" do
      expect(headers.keys.size).to eq 2
    end

    it "normalizes keys" do
      expect(headers.keys).to include("Content-Type", "Set-Cookie")
    end
  end

  describe "#each" do
    before do
      headers.add :set_cookie,   "hoo=ray"
      headers.add :content_type, "application/json"
      headers.add :set_cookie,   "woo=hoo"
    end

    it "yields each key/value pair separatedly" do
      expect { |b| headers.each(&b) }.to yield_control.exactly(3).times
    end

    it "yields headers in the same order they were added" do
      expect { |b| headers.each(&b) }.to yield_successive_args(
        %w[Set-Cookie hoo=ray],
        %w[Content-Type application/json],
        %w[Set-Cookie woo=hoo]
      )
    end

    it "returns self instance if block given" do
      expect(headers.each { |*| }).to be headers
    end

    it "returns Enumerator if no block given" do
      expect(headers.each).to be_a Enumerator
    end
  end

  describe ".empty?" do
    subject { headers.empty? }

    context "initially" do
      it { is_expected.to be true }
    end

    context "when header exists" do
      before { headers.add :accept, "text/plain" }
      it { is_expected.to be false }
    end

    context "when last header was removed" do
      before do
        headers.add :accept, "text/plain"
        headers.delete :accept
      end

      it { is_expected.to be true }
    end
  end

  describe "#hash" do
    let(:left)  { described_class.new }
    let(:right) { described_class.new }

    it "equals if two headers equals" do
      left.add :accept, "text/plain"
      right.add :accept, "text/plain"

      expect(left.hash).to eq right.hash
    end
  end

  describe "#==" do
    let(:left)  { described_class.new }
    let(:right) { described_class.new }

    it "compares header keys and values" do
      left.add :accept, "text/plain"
      right.add :accept, "text/plain"

      expect(left).to eq right
    end

    it "allows comparison with Array of key/value pairs" do
      left.add :accept, "text/plain"
      expect(left).to eq [%w[Accept text/plain]]
    end

    it "sensitive to headers order" do
      left.add :accept, "text/plain"
      left.add :cookie, "woo=hoo"
      right.add :cookie, "woo=hoo"
      right.add :accept, "text/plain"

      expect(left).to_not eq right
    end

    it "sensitive to header values order" do
      left.add :cookie, "hoo=ray"
      left.add :cookie, "woo=hoo"
      right.add :cookie, "woo=hoo"
      right.add :cookie, "hoo=ray"

      expect(left).to_not eq right
    end
  end

  describe "#dup" do
    before { headers.set :content_type, "application/json" }

    subject(:dupped) { headers.dup }

    it { is_expected.to be_a described_class }
    it { is_expected.not_to be headers }

    it "has headers copied" do
      expect(dupped[:content_type]).to eq "application/json"
    end

    context "modifying a copy" do
      before { dupped.set :content_type, "text/plain" }

      it "modifies dupped copy" do
        expect(dupped[:content_type]).to eq "text/plain"
      end

      it "does not affects original headers" do
        expect(headers[:content_type]).to eq "application/json"
      end
    end
  end

  describe "#merge!" do
    before do
      headers.set :host, "example.com"
      headers.set :accept, "application/json"
      headers.merge! :accept => "plain/text", :cookie => %w[hoo=ray woo=hoo]
    end

    it "leaves headers not presented in other as is" do
      expect(headers[:host]).to eq "example.com"
    end

    it "overwrites existing values" do
      expect(headers[:accept]).to eq "plain/text"
    end

    it "appends other headers, not presented in base" do
      expect(headers[:cookie]).to eq %w[hoo=ray woo=hoo]
    end
  end

  describe "#merge" do
    before do
      headers.set :host, "example.com"
      headers.set :accept, "application/json"
    end

    subject(:merged) do
      headers.merge :accept => "plain/text", :cookie => %w[hoo=ray woo=hoo]
    end

    it { is_expected.to be_a described_class }
    it { is_expected.not_to be headers }

    it "does not affects original headers" do
      expect(merged.to_h).to_not eq headers.to_h
    end

    it "leaves headers not presented in other as is" do
      expect(merged[:host]).to eq "example.com"
    end

    it "overwrites existing values" do
      expect(merged[:accept]).to eq "plain/text"
    end

    it "appends other headers, not presented in base" do
      expect(merged[:cookie]).to eq %w[hoo=ray woo=hoo]
    end
  end

  describe ".coerce" do
    let(:dummyClass) { Class.new { def respond_to?(*); end } }

    it "accepts any object that respond to #to_hash" do
      hashie = double :to_hash => {"accept" => "json"}
      expect(described_class.coerce(hashie)["accept"]).to eq "json"
    end

    it "accepts any object that respond to #to_h" do
      hashie = double :to_h => {"accept" => "json"}
      expect(described_class.coerce(hashie)["accept"]).to eq "json"
    end

    it "accepts any object that respond to #to_a" do
      hashie = double :to_a => [%w[accept json]]
      expect(described_class.coerce(hashie)["accept"]).to eq "json"
    end

    it "fails if given object cannot be coerced" do
      expect { described_class.coerce dummyClass.new }.to raise_error HTTP::Error
    end

    context "with duplicate header keys (mixed case)" do
      let(:headers) { {"Set-Cookie" => "hoo=ray", "set-cookie" => "woo=hoo"} }

      it "adds all headers" do
        expect(described_class.coerce(headers).to_a).
          to match_array(
            [
              %w[Set-Cookie hoo=ray],
              %w[Set-Cookie woo=hoo]
            ]
          )
      end
    end

    it "is aliased as .[]" do
      expect(described_class.method(:coerce)).to eq described_class.method(:[])
    end
  end
end
