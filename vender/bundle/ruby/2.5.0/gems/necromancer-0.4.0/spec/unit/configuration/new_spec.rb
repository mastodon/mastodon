# encoding: utf-8

RSpec.describe Necromancer::Configuration, '.new' do

  subject(:config) { described_class.new }

  it { is_expected.to respond_to(:strict=) }

  it { is_expected.to respond_to(:copy=) }

  it "is in non-strict mode by default" do
    expect(config.strict).to eq(false)
  end

  it "is in copy mode by default" do
    expect(config.copy).to eq(true)
  end

  it "allows to set strict through method" do
    config.strict true
    expect(config.strict).to eq(true)
  end

  it "allows to set copy mode through method" do
    config.copy false
    expect(config.strict).to eq(false)
  end
end
