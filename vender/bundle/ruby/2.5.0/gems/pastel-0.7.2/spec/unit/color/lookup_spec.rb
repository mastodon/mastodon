# encoding: utf-8

RSpec.describe Pastel::Color, '#lookup' do
  it "looksup colors" do
    color = described_class.new(enabled: true)
    expect(color.lookup(:red, :on_green, :bold)).to eq("\e[31;42;1m")
  end

  it "caches color lookups" do
    color = described_class.new(enabled: true)
    allow(color).to receive(:code).and_return([31])
    color.lookup(:red, :on_green)
    color.lookup(:red, :on_green)
    color.lookup(:red, :on_green)
    expect(color).to have_received(:code).once
  end
end
