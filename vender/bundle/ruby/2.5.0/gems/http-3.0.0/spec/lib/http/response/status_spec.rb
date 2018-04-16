# frozen_string_literal: true

RSpec.describe HTTP::Response::Status do
  describe ".new" do
    it "fails if given value does not respond to #to_i" do
      expect { described_class.new double }.to raise_error TypeError
    end

    it "accepts any object that responds to #to_i" do
      expect { described_class.new double :to_i => 200 }.to_not raise_error
    end
  end

  describe "#code" do
    subject { described_class.new("200.0").code }
    it { is_expected.to eq 200 }
    it { is_expected.to be_a Integer }
  end

  describe "#reason" do
    subject { described_class.new(code).reason }

    context "with unknown code" do
      let(:code) { 1024 }
      it { is_expected.to be_nil }
    end

    described_class::REASONS.each do |code, reason|
      class_eval <<-RUBY
        context 'with well-known code: #{code}' do
          let(:code) { #{code} }
          it { is_expected.to eq #{reason.inspect} }
          it { is_expected.to be_frozen }
        end
      RUBY
    end
  end

  context "with 1xx codes" do
    subject { (100...200).map { |code| described_class.new code } }

    it "is #informational?" do
      expect(subject).to all(satisfy(&:informational?))
    end

    it "is not #success?" do
      expect(subject).to all(satisfy { |status| !status.success? })
    end

    it "is not #redirect?" do
      expect(subject).to all(satisfy { |status| !status.redirect? })
    end

    it "is not #client_error?" do
      expect(subject).to all(satisfy { |status| !status.client_error? })
    end

    it "is not #server_error?" do
      expect(subject).to all(satisfy { |status| !status.server_error? })
    end
  end

  context "with 2xx codes" do
    subject { (200...300).map { |code| described_class.new code } }

    it "is not #informational?" do
      expect(subject).to all(satisfy { |status| !status.informational? })
    end

    it "is #success?" do
      expect(subject).to all(satisfy(&:success?))
    end

    it "is not #redirect?" do
      expect(subject).to all(satisfy { |status| !status.redirect? })
    end

    it "is not #client_error?" do
      expect(subject).to all(satisfy { |status| !status.client_error? })
    end

    it "is not #server_error?" do
      expect(subject).to all(satisfy { |status| !status.server_error? })
    end
  end

  context "with 3xx codes" do
    subject { (300...400).map { |code| described_class.new code } }

    it "is not #informational?" do
      expect(subject).to all(satisfy { |status| !status.informational? })
    end

    it "is not #success?" do
      expect(subject).to all(satisfy { |status| !status.success? })
    end

    it "is #redirect?" do
      expect(subject).to all(satisfy(&:redirect?))
    end

    it "is not #client_error?" do
      expect(subject).to all(satisfy { |status| !status.client_error? })
    end

    it "is not #server_error?" do
      expect(subject).to all(satisfy { |status| !status.server_error? })
    end
  end

  context "with 4xx codes" do
    subject { (400...500).map { |code| described_class.new code } }

    it "is not #informational?" do
      expect(subject).to all(satisfy { |status| !status.informational? })
    end

    it "is not #success?" do
      expect(subject).to all(satisfy { |status| !status.success? })
    end

    it "is not #redirect?" do
      expect(subject).to all(satisfy { |status| !status.redirect? })
    end

    it "is #client_error?" do
      expect(subject).to all(satisfy(&:client_error?))
    end

    it "is not #server_error?" do
      expect(subject).to all(satisfy { |status| !status.server_error? })
    end
  end

  context "with 5xx codes" do
    subject { (500...600).map { |code| described_class.new code } }

    it "is not #informational?" do
      expect(subject).to all(satisfy { |status| !status.informational? })
    end

    it "is not #success?" do
      expect(subject).to all(satisfy { |status| !status.success? })
    end

    it "is not #redirect?" do
      expect(subject).to all(satisfy { |status| !status.redirect? })
    end

    it "is not #client_error?" do
      expect(subject).to all(satisfy { |status| !status.client_error? })
    end

    it "is #server_error?" do
      expect(subject).to all(satisfy(&:server_error?))
    end
  end

  describe "#to_sym" do
    subject { described_class.new(code).to_sym }

    context "with unknown code" do
      let(:code) { 1024 }
      it { is_expected.to be_nil }
    end

    described_class::SYMBOLS.each do |code, symbol|
      class_eval <<-RUBY
        context 'with well-known code: #{code}' do
          let(:code) { #{code} }
          it { is_expected.to be #{symbol.inspect} }
        end
      RUBY
    end
  end

  describe "#inspect" do
    it "returns quoted code and reason phrase" do
      status = described_class.new 200
      expect(status.inspect).to eq "#<HTTP::Response::Status 200 OK>"
    end
  end

  # testing edge cases only
  describe "::SYMBOLS" do
    subject { described_class::SYMBOLS }

    # "OK"
    its([200]) { is_expected.to be :ok }

    # "Bad Request"
    its([400]) { is_expected.to be :bad_request }
  end

  described_class::SYMBOLS.each do |code, symbol|
    class_eval <<-RUBY
      describe '##{symbol}?' do
        subject { status.#{symbol}? }

        context 'when code is #{code}' do
          let(:status) { described_class.new #{code} }
          it { is_expected.to be true }
        end

        context 'when code is higher than #{code}' do
          let(:status) { described_class.new #{code + 1} }
          it { is_expected.to be false }
        end

        context 'when code is lower than #{code}' do
          let(:status) { described_class.new #{code - 1} }
          it { is_expected.to be false }
        end
      end
    RUBY
  end

  describe ".coerce" do
    context "with String" do
      it "coerces reasons" do
        expect(described_class.coerce("Bad request")).to eq described_class.new 400
      end

      it "fails when reason is unknown" do
        expect { described_class.coerce "foobar" }.to raise_error HTTP::Error
      end
    end

    context "with Symbol" do
      it "coerces symbolized reasons" do
        expect(described_class.coerce(:bad_request)).to eq described_class.new 400
      end

      it "fails when symbolized reason is unknown" do
        expect { described_class.coerce(:foobar) }.to raise_error HTTP::Error
      end
    end

    context "with Numeric" do
      it "coerces as Fixnum code" do
        expect(described_class.coerce(200.1)).to eq described_class.new 200
      end
    end

    it "fails if coercion failed" do
      expect { described_class.coerce(true) }.to raise_error HTTP::Error
    end

    it "is aliased as `.[]`" do
      expect(described_class.method(:coerce)).to eq described_class.method :[]
    end
  end
end
