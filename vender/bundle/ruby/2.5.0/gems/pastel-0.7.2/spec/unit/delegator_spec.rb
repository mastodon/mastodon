# coding: utf-8

RSpec.describe Pastel::Delegator do

  it "returns delegator for color without argument" do
    pastel = Pastel.new(enabled: true)
    expect(pastel.red).to be_a(Pastel::Delegator)
  end

  describe ".inspect" do
    it "inspects delegator styles chain" do
      chain = ['red', 'on_green']
      delegator = described_class.new(:resolver, chain)
      allow(delegator).to receive(:styles).and_return({red: 31, on_green: 42})
      expect(delegator.inspect).to eq("#<Pastel @styles=[\"red\", \"on_green\"]>")
    end
  end

  describe ".respond_to_missing?" do
    context 'for a method defined on' do
      it "returns true" do
        resolver = double(:resolver)
        chain = double(:chain)
        decorator = described_class.new(resolver, chain)
        expect(decorator.method(:styles)).not_to be_nil
      end
    end

    context "for an undefined method " do
      it "returns false" do
        resolver = double(:resolver, color: true)
        chain = double(:chain)
        decorator = described_class.new(resolver, chain)
        expect { decorator.method(:unknown) }.to raise_error(NameError)
      end
    end
  end
end
