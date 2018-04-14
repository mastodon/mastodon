# encoding: utf-8

RSpec.describe Pastel::Color, '.alias_color' do

  subject(:color) { described_class.new(enabled: true) }

  it 'aliases non existent color' do
    expect {
      color.alias_color(:funky, :unknown)
    }.to raise_error(Pastel::InvalidAttributeNameError)
  end

  it 'aliases color with invalid name' do
    expect {
      color.alias_color('some name', :red)
    }.to raise_error(Pastel::InvalidAliasNameError, /Invalid alias name/)
  end

  it 'aliases standard color' do
    expect {
      color.alias_color(:red, :red)
    }.to raise_error(Pastel::InvalidAliasNameError, /alias standard color/)
  end

  it 'aliases color :red to :funky' do
    color.alias_color(:funky, :red, :bold)
    expect(color.valid?(:funky)).to eq(true)
    expect(color.code(:funky)).to eq([[31, 1]])
    expect(color.lookup(:funky)).to eq("\e[31;1m")
  end

  it "has global aliases" do
    color_foo = described_class.new(enabled: true)
    color_bar = described_class.new(enabled: true)
    color_foo.alias_color(:foo, :red)
    color_bar.alias_color(:bar, :red)
    expect(color_foo.valid?(:foo)).to eq(true)
    expect(color_foo.valid?(:bar)).to eq(true)
  end
end
