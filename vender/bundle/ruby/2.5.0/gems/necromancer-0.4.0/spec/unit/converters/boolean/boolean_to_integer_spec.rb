# encoding: utf-8

RSpec.describe Necromancer::BooleanConverters::BooleanToIntegerConverter, '.call' do

  subject(:converter) { described_class.new }

  it "converts true to 1 value" do
    expect(converter.call(true)).to eq(1)
  end

  it "converts false to 0 value" do
    expect(converter.call(false)).to eq(0)
  end

  it "fails to convert in strict mode" do
    expect {
      converter.call('unknown', strict: true)
    }.to raise_error(Necromancer::ConversionTypeError)
  end

  it "returns value in non-strict mode" do
    expect(converter.call('unknown', strict: false)).to eq('unknown')
  end
end
