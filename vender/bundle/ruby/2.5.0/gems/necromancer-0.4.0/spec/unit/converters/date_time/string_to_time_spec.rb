# encoding: utf-8

RSpec.describe Necromancer::DateTimeConverters::StringToTimeConverter, '.call' do

  subject(:converter) { described_class.new(:string, :time) }

  it "converts to time instance" do
    expect(converter.call('01/01/2015')).to be_a(Time)
  end

  it "converts '01/01/2015' to time value" do
    expect(converter.call('01/01/2015')).to eq(Time.parse('01/01/2015'))
  end

  it "converts '01/01/2015 08:35' to time value" do
    expect(converter.call('01/01/2015 08:35')).to eq(Time.parse('01/01/2015 08:35'))
  end

  it "converts '12:35' to time value" do
    expect(converter.call('12:35')).to eq(Time.parse('12:35'))
  end

  it "fails to convert in strict mode" do
    expect {
      converter.call('11-13-2015', strict: true)
    }.to raise_error(Necromancer::ConversionTypeError)
  end
end
