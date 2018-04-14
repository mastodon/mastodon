# encoding: utf-8

RSpec.describe Pastel::Color, '#colored?' do
  subject(:color) { described_class.new(enabled: true) }

  it "checks if string has color codes" do
    string = "foo\e[31mbar\e[0m"
    expect(color.colored?(string)).to eq(true)
  end

  it "checks that string doesn't contain color codes" do
    string = "foo\nbar"
    expect(color.colored?(string)).to eq(false)
  end
end
