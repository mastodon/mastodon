# encoding: utf-8

RSpec.describe Necromancer::ArrayConverters::ArrayToSetConverter, '.call' do

  subject(:converter) { described_class.new(:array, :set) }

  it "converts `[:x,:y,:x,1,2,1]` to set" do
    expect(converter.call([:x,:y,:x,1,2,1])).to eql(Set[:x,:y,1,2])
  end

  it "fails to convert `1` to set" do
    expect {
      converter.call(1, strict: true)
    }.to raise_error(Necromancer::ConversionTypeError)
  end
end
