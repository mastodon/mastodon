# coding: utf-8

RSpec.describe Pastel, '#alias_color' do

  subject(:pastel) { described_class.new(enabled: true) }

  it "aliases color" do
    pastel.alias_color(:funky, :red, :bold)
    expect(pastel.funky('unicorn')).to eq("\e[31;1municorn\e[0m")
  end

  it "aliases color and combines with regular ones" do
    pastel.alias_color(:funky, :red, :bold)
    expect(pastel.funky.on_green('unicorn')).to eq("\e[31;1;42municorn\e[0m")
  end

  it "reads aliases from the environment" do
    color_aliases = "funky=red"
    allow(ENV).to receive(:[]).with('PASTEL_COLORS_ALIASES').
      and_return(color_aliases)
    described_class.new(enabled: true)
    expect(pastel.valid?(:funky)).to eq(true)
  end
end
