# encoding: utf-8

RSpec.describe Necromancer::RangeConverters::StringToRangeConverter, '.call' do

  subject(:converter) { described_class.new }

  it "raises error for empty string in strict mode" do
    expect {
      converter.call('', strict: true)
    }.to raise_error(Necromancer::ConversionTypeError)
  end

  it "returns value in non-strict mode" do
    expect(converter.call('', strict: false)).to eq('')
  end

  {
    '1'     => 1..1,
    '1..10' => 1..10,
    '1-10'  => 1..10,
    '1,10'  => 1..10,
    '1...10' => 1...10,
    '-1..10' => -1..10,
    '1..-10' => 1..-10,
    'a..z' => 'a'..'z',
    'a-z' => 'a'..'z',
    'A-Z' => 'A'..'Z'
  }.each do |actual, expected|
    it "converts '#{actual}' to range type" do
      expect(converter.call(actual)).to eql(expected)
    end
  end
end
