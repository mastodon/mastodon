# encoding: utf-8

RSpec.describe Necromancer, '.inspect' do
  subject(:converter) { described_class.new }

  it "inspects converter instance" do
    expect(converter.inspect).to eq("#<Necromancer::Context@#{converter.object_id} @config=#{converter.configuration}>")
  end

  it "inspects conversion target" do
    conversion = converter.convert(11)
    expect(conversion.inspect).to eq("#<Necromancer::ConversionTarget@#{conversion.object_id} @object=11, @source=integer>")
  end
end
