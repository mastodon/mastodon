# encoding: utf-8

RSpec.describe Necromancer::ArrayConverters::ArrayToBooleanConverter, '.call' do

  subject(:converter) { described_class.new(:array, :boolean) }

  it "converts `['t', 'f', 'yes', 'no']` to boolean array" do
    expect(converter.call(['t', 'f', 'yes', 'no'])).to eq([true, false, true, false])
  end

  it "fails to convert `['t', 'no', 5]` to boolean array in strict mode" do
    expect {
      converter.call(['t', 'no', 5], strict: true)
    }.to raise_error(Necromancer::ConversionTypeError)
  end

  it "converts `['t', 'no', 5]` to boolean array in non-strict mode" do
    expect(converter.call(['t', 'no', 5], strict: false)).to eql([true, false, 5])
  end
end
