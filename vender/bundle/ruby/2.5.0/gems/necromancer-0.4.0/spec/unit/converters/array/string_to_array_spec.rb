# encoding: utf-8

RSpec.describe Necromancer::ArrayConverters::StringToArrayConverter, '.call' do
  subject(:converter) { described_class.new(:string, :array) }

  it "converts empty string to array" do
    expect(converter.call('', strict: false)).to eq([''])
  end

  it "fails to convert empty string to array in strict mode" do
    expect {
      converter.call('', strict: true)
    }.to raise_error(Necromancer::ConversionTypeError)
  end

  it "converts `1,2,3` to array" do
    expect(converter.call('1,2,3')).to eq([1,2,3])
  end

  it "converts `a,b,c` to array" do
    expect(converter.call('a,b,c')).to eq(['a','b','c'])
  end

  it "converts '1-2-3' to array" do
    expect(converter.call('1-2-3')).to eq([1,2,3])
  end

  it "converts ' 1 - 2 - 3 ' to array" do
    expect(converter.call('  1 - 2 - 3 ')).to eq([1,2,3])
  end
end
