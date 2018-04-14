# encoding: utf-8

RSpec.describe Necromancer::NumericConverters::StringToNumericConverter, '.call' do

  subject(:converter) { described_class.new(:string, :numeric) }

  {
    '1'       => 1,
    '+1'      => 1,
    '-1'      => -1,
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
    it "converts '#{actual}' to '#{expected}'" do
      expect(converter.call(actual)).to eql(expected)
    end
  end
end
