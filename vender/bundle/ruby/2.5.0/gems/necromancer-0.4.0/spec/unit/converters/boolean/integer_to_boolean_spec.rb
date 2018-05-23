# encoding: utf-8

RSpec.describe Necromancer::BooleanConverters::IntegerToBooleanConverter, '.call' do

  subject(:converter) { described_class.new }

  it "converts 1 to true value" do
    expect(converter.call(1)).to eq(true)
  end

  it "converts 0 to false value" do
    expect(converter.call(0)).to eq(false)
  end

  it "fails to convert in strict mode" do
    expect  {
      converter.call('1', strict: true)
    }.to raise_error(Necromancer::ConversionTypeError)
  end
end
