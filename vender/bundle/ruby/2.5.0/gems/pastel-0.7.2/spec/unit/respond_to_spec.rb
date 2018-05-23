# coding: utf-8

RSpec.describe Pastel, '.respond_to?' do
  subject(:pastel) { described_class.new(enabled: true) }

  it "responds correctly to color method" do
    expect(pastel.respond_to?(:decorate)).to eq(true)
  end

  it "responds correctly to color property" do
    expect(pastel.respond_to?(:red)).to eq(true)
  end

  it "responds correctly to unkown method" do
    expect(pastel.respond_to?(:unknown)).to eq(false)
  end
end
