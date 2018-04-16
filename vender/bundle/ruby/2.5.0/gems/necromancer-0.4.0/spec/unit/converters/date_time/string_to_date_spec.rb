# encoding: utf-8

RSpec.describe Necromancer::DateTimeConverters::StringToDateConverter, '.call' do

  subject(:converter) { described_class.new(:string, :date) }

  it "converts '1-1-2015' to date value" do
    expect(converter.call('1-1-2015')).to eq(Date.parse('2015/01/01'))
  end

  it "converts '2014/12/07' to date value" do
    expect(converter.call('2014/12/07')).to eq(Date.parse('2014/12/07'))
  end

  it "converts '2014-12-07' to date value" do
    expect(converter.call('2014-12-07')).to eq(Date.parse('2014/12/07'))
  end

  it "fails to convert in strict mode" do
    expect {
      converter.call('2014 - 12 - 07', strict: true)
    }.to raise_error(Necromancer::ConversionTypeError)
  end
end
