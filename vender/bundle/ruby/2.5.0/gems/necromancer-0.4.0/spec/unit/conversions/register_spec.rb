# encoding: utf-8

RSpec.describe Necromancer::Conversions, '.register' do
  it "allows to register converter" do
    context = described_class.new
    converter = double(:converter, {source: :string, target: :numeric})
    expect(context.register(converter)).to eq(true)
    expect(context[:string, :numeric]).to eq(converter)
  end

  it "allows to register converter with no source" do
    context = described_class.new
    converter = double(:converter, {source: nil, target: :numeric})
    expect(context.register(converter)).to eq(true)
    expect(context[:none, :numeric]).to eq(converter)
  end

  it "allows to register converter with no target" do
    context = described_class.new
    converter = double(:converter, {source: :string, target: nil})
    expect(context.register(converter)).to eq(true)
    expect(context[:string, :none]).to eq(converter)
  end

  it "allows to register anonymous converter" do
    conversions = described_class.new

    conversions.register do |c|
      c.source= :string
      c.target= :upcase
      c.convert = proc { |value| value.to_s.upcase }
    end
    expect(conversions[:string, :upcase].call('magic')).to eq('MAGIC')
  end

  it "allows to register anonymous converter with class names" do
    conversions = described_class.new

    conversions.register do |c|
      c.source= String
      c.target= Array
      c.convert = proc { |value| Array(value) }
    end
    expect(conversions[String, Array].call('magic')).to eq(['magic'])
  end

  it "allows to register custom converter" do
    conversions = described_class.new
    UpcaseConverter = Struct.new(:source, :target) do
      def call(value)
        value.to_s.upcase
      end
    end
    upcase_converter = UpcaseConverter.new(:string, :upcase)
    expect(conversions.register(upcase_converter)).to be(true)
    expect(conversions[:string, :upcase].call('magic')).to eq('MAGIC')
  end
end
