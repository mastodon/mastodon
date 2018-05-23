# encoding: utf-8

RSpec.describe Necromancer::ArrayConverters::ObjectToArrayConverter, '.call' do
  subject(:converter) { described_class.new(:object, :array) }

  it "converts nil to array" do
    expect(converter.call(nil)).to eq([])
  end

  it "converts custom object to array" do
    Custom = Class.new do
      def to_ary
        [:x, :y]
      end
    end
    custom = Custom.new
    expect(converter.call(custom)).to eq([:x, :y])
  end
end
