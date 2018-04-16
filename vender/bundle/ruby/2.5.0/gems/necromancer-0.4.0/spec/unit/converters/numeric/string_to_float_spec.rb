# encoding: utf-8

RSpec.describe Necromancer::NumericConverters::StringToFloatConverter, '.call' do

  subject(:converter) { described_class.new(:string, :float) }

  it "raises error for empty string in strict mode" do
    expect {
      converter.call('', strict: true)
    }.to raise_error(Necromancer::ConversionTypeError)
  end

  {
    '1'       => 1.0,
    '+1'      => 1.0,
    '-1'      => -1.0,
    '1e1'     => 10.0,
    '1e-1'    => 0.1,
    '-1e1'    => -10.0,
    '-1e-1'   => -0.1,
    '1.0'     => 1.0,
    '1.0e+1'  => 10.0,
    '1.0e-1'  => 0.1,
    '-1.0e+1' => -10.0,
    '-1.0e-1' => -0.1,
    '.1'      => 0.1,
    '.1e+1'   => 1.0,
    '.1e-1'   => 0.01,
    '-.1e+1'  => -1.0,
    '-.1e-1'  => -0.01
  }.each do |actual, expected|
    it "converts '#{actual}' to float value" do
      expect(converter.call(actual)).to eql(expected)
    end
  end

  it "failse to convert '1.2a' in strict mode" do
    expect {
      converter.call('1.2a', strict: true)
    }.to raise_error(Necromancer::ConversionTypeError)
  end

  it "converts '1.2a' in non-strict mode" do
    expect(converter.call('1.2a', strict: false)).to eq(1.2)
  end
end
