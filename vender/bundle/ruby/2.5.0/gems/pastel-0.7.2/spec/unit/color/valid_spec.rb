# encoding: utf-8

RSpec.describe Pastel::Color, '.valid?' do
  it "detects valid colors" do
    color = described_class.new
    expect(color.valid?(:red, :on_green, :bold)).to eq(true)
  end

  it "detects valid color aliases" do
    color = described_class.new
    color.alias_color(:funky, :red)
    expect(color.valid?(:funky)).to eq(true)
  end

  it "detects invalid color" do
    color = described_class.new
    expect(color.valid?(:red, :unknown)).to eq(false)
  end
end
