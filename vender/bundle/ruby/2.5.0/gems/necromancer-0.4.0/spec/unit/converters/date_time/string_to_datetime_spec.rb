# encoding: utf-8

RSpec.describe Necromancer::DateTimeConverters::StringToDateTimeConverter, '.call' do

  subject(:converter) { described_class.new(:string, :datetime) }

  it "converts '2014/12/07' to date value" do
    expect(converter.call('2014/12/07')).to eq(DateTime.parse('2014/12/07'))
  end

  it "converts '2014-12-07' to date value" do
    expect(converter.call('2014-12-07')).to eq(DateTime.parse('2014-12-07'))
  end

  it "converts '7th December 2014' to datetime value" do
    expect(converter.call('7th December 2014')).
      to eq(DateTime.parse('2014-12-07'))
  end

  it "converts '7th December 2014 17:19:44' to datetime value" do
    expect(converter.call('7th December 2014 17:19:44')).
      to eq(DateTime.parse('2014-12-07 17:19:44'))
  end

  it "fails to convert in strict mode" do
    expect {
      converter.call('2014 - 12 - 07', strict: true)
    }.to raise_error(Necromancer::ConversionTypeError)
  end
end
