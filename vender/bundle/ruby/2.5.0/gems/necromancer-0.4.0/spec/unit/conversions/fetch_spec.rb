# encoding: utf-8

RSpec.describe Necromancer::Conversions, '#fetch' do
  it "retrieves conversion given source & target" do
    converter = double(:converter)
    conversions = described_class.new nil, {'string->array' => converter}
    expect(conversions['string', 'array']).to eq(converter)
  end

  it "fails to find conversion" do
    conversions = described_class.new
    expect {
      conversions['string', 'array']
    }.to raise_error(Necromancer::NoTypeConversionAvailableError)
  end
end
