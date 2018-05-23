# encoding: utf-8

RSpec.describe Necromancer::ArrayConverters::ArrayToNumericConverter, '.call' do

  subject(:converter) { described_class.new(:array, :numeric) }

  it "converts `['1','2.3','3.0']` to numeric array" do
    expect(converter.call(['1', '2.3', '3.0'])).to eq([1, 2.3, 3.0])
  end

  it "fails to convert `['1','2.3',false]` to numeric array in strict mode" do
    expect {
      converter.call(['1', '2.3', false], strict: true)
    }.to raise_error(Necromancer::ConversionTypeError)
  end

  it "converts `['1','2.3',false]` to numeric array in non-strict mode" do
    expect(converter.call(['1', '2.3', false], strict: false)).to eq([1, 2.3, false])
  end
end
