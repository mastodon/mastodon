# encoding: utf-8

RSpec.describe Necromancer::BooleanConverters::StringToBooleanConverter, '.call' do

  subject(:converter) { described_class.new(:string, :boolean) }

  it "raises error for empty string strict mode" do
    expect {
      converter.call('', strict: true)
    }.to raise_error(Necromancer::ConversionTypeError)
  end

  it "fails to convert unkonwn value FOO" do
    expect {
      converter.call('FOO', strict: true)
    }.to raise_error(Necromancer::ConversionTypeError)
  end

  it "passes through boolean value" do
    expect(converter.call(true)).to eq(true)
  end

  %w[true TRUE t T 1 y Y YES yes on ON].each do |value|
    it "converts '#{value}' to true value" do
      expect(converter.call(value)).to eq(true)
    end
  end

  %w[false FALSE f F 0 n N NO No no off OFF].each do |value|
    it "converts '#{value}' to false value" do
      expect(converter.call(value)).to eq(false)
    end
  end
end
