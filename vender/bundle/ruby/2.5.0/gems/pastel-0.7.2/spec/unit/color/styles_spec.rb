# coding: utf-8

RSpec.describe Pastel::Color, '#styles' do

  subject(:color) { described_class.new(enabled: true) }

  it "exposes all available style ANSI codes" do
    expect(color.styles[:red]).to eq(31)
  end
end
