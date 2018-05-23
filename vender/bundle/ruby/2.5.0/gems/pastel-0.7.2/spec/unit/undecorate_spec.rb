# encoding: utf-8

RSpec.describe Pastel, '#undecorate' do
  subject(:pastel) { described_class.new(enabled: true) }

  it "undecorates string detecting color escape codes" do
    string = pastel.red.on_green('foo')
    expect(pastel.undecorate(string)).to eq([
      {foreground: :red, background: :on_green, text: 'foo'}
    ])
  end
end
