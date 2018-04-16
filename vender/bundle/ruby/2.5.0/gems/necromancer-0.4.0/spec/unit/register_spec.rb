# encoding: utf-8

RSpec.describe Necromancer, '.register' do
  it "allows ro register converter" do
    converter = described_class.new
    UpcaseConverter = Struct.new(:source, :target) do
      def call(value, options)
        value.to_s.upcase
      end
    end
    upcase_converter = UpcaseConverter.new(:string, :upcase)
    expect(converter.register(upcase_converter)).to eq(true)
    expect(converter.convert('magic').to(:upcase)).to eq('MAGIC')
  end
end
