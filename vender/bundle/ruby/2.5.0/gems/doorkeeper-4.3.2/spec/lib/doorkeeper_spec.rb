require 'spec_helper_integration'

describe Doorkeeper do
  describe "#authenticate" do
    let(:request) { double }

    it "calls OAuth::Token#authenticate" do
      token_strategies = Doorkeeper.configuration.access_token_methods

      expect(Doorkeeper::OAuth::Token).to receive(:authenticate).
        with(request, *token_strategies)

      Doorkeeper.authenticate(request)
    end

    it "accepts custom token strategies" do
      token_strategies = [:first_way, :second_way]

      expect(Doorkeeper::OAuth::Token).to receive(:authenticate).
        with(request, *token_strategies)

      Doorkeeper.authenticate(request, token_strategies)
    end
  end

  describe "#configured?" do
    after do
      Doorkeeper.remove_instance_variable(:@config)
    end

    context "@config is set" do
      it "returns true" do
        Doorkeeper.instance_variable_set(:@config, "hi")

        expect(Doorkeeper.configured?).to eq(true)
      end
    end

    context "@config is not set" do
      it "returns false" do
        Doorkeeper.instance_variable_set(:@config, nil)

        expect(Doorkeeper.configured?).to eq(false)
      end
    end

    it "is deprecated" do
      expect(ActiveSupport::Deprecation).to receive(:warn).
        with("Method `Doorkeeper#configured?` has been deprecated without replacement.")

      Doorkeeper.configured?
    end
  end

  describe "#database_installed?" do
    before do
      ["AccessToken", "AccessGrant", "Application"].each do |klass|
        @original_classes ||= {}
        @original_classes[klass] = Doorkeeper.const_get(klass)
        Doorkeeper.send(:remove_const, klass)
      end
    end

    after do
      ["AccessToken", "AccessGrant", "Application"].each do |klass|
        Doorkeeper.send(:remove_const, klass)
        Doorkeeper.const_set(klass, @original_classes[klass])
      end
    end

    context "all tables exist" do
      before do
        klass = double table_exists?: true

        Doorkeeper.const_set(:AccessToken, klass)
        Doorkeeper.const_set(:AccessGrant, klass)
        Doorkeeper.const_set(:Application, klass)
      end

      it "returns true" do
        expect(Doorkeeper.database_installed?).to eq(true)
      end

      it "is deprecated" do
        expect(ActiveSupport::Deprecation).to receive(:warn).
          with("Method `Doorkeeper#database_installed?` has been deprecated without replacement.")

        Doorkeeper.database_installed?
      end
    end

    context "all tables do not exist" do
      before do
        klass = double table_exists?: false

        Doorkeeper.const_set(:AccessToken, klass)
        Doorkeeper.const_set(:AccessGrant, klass)
        Doorkeeper.const_set(:Application, klass)
      end

      it "returns false" do
        expect(Doorkeeper.database_installed?).to eq(false)
      end

      it "is deprecated" do
        expect(ActiveSupport::Deprecation).to receive(:warn).
          with("Method `Doorkeeper#database_installed?` has been deprecated without replacement.")

        Doorkeeper.database_installed?
      end
    end
  end

  describe "#installed?" do
    context "methods return true" do
      before do
        allow(Doorkeeper).to receive(:configured?).and_return(true).once
        allow(Doorkeeper).to receive(:database_installed?).and_return(true).once
      end

      it "returns true" do
        expect(Doorkeeper.installed?).to eq(true)
      end
    end

    context "methods return false" do
      before do
        allow(Doorkeeper).to receive(:configured?).and_return(false).once
        allow(Doorkeeper).to receive(:database_installed?).and_return(false).once
      end

      it "returns false" do
        expect(Doorkeeper.installed?).to eq(false)
      end
    end

    it "is deprecated" do
      expect(ActiveSupport::Deprecation).to receive(:warn).
        with("Method `Doorkeeper#configured?` has been deprecated without replacement.")

      expect(ActiveSupport::Deprecation).to receive(:warn).
        with("Method `Doorkeeper#database_installed?` has been deprecated without replacement.")

      expect(ActiveSupport::Deprecation).to receive(:warn).
        with("Method `Doorkeeper#installed?` has been deprecated without replacement.")

      Doorkeeper.installed?
    end
  end
end
