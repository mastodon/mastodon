# encoding: utf-8

RSpec.describe Necromancer, 'config' do
  it "configures global settings per instance" do
    converter = described_class.new

    converter.configure do |config|
      config.strict false
    end
    expect(converter.convert("1.2.3").to(:array)).to eq(["1.2.3"])

    converter.configure do |config|
      config.strict true
    end
    expect {
      converter.convert("1.2.3").to(:array)
    }.to raise_error(Necromancer::ConversionTypeError)
  end

  it "configures global settings through instance block" do
    converter = described_class.new do |config|
      config.strict true
    end
    expect(converter.configuration.strict).to eq(true)

    expect {
      converter.convert("1.2.3").to(:array)
    }.to raise_error(Necromancer::ConversionTypeError)
  end
end
