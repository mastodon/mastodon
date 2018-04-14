# encoding: utf-8

RSpec.describe Pastel::Color, '.decorate' do
  let(:string) { 'string' }

  subject(:color) { described_class.new(enabled: true) }

  it "doesn't output styling when disabled" do
    color = described_class.new(enabled: false)
    expect(color.decorate('foo', :red)).to eq('foo')
  end

  it "doesn't apply styling to empty string" do
    expect(color.decorate('')).to eq('')
  end

  it "doesn't decorate without color" do
    expect(color.decorate(string)).to eq(string)
  end

  it 'applies green text to string' do
    expect(color.decorate(string, :green)).to eq("\e[32m#{string}\e[0m")
  end

  it 'applies red text background to string' do
    expect(color.decorate(string, :on_red)).to eq("\e[41m#{string}\e[0m")
  end

  it 'applies style and color to string' do
    expect(color.decorate(string, :bold, :green)).to eq("\e[1;32m#{string}\e[0m")
  end

  it 'applies style, color and background to string' do
    text = color.decorate(string, :bold, :green, :on_blue)
    expect(text).to eq("\e[1;32;44m#{string}\e[0m")
  end

  it "applies styles to nested text" do
    decorated = color.decorate(string + color.decorate(string, :red) + string, :green)
    expect(decorated).to eq("\e[32m#{string}\e[31m#{string}\e[0m\e[32m#{string}\e[0m")
  end

  it "decorates multiline string as regular by default" do
    string = "foo\nbar\nbaz"
    expect(color.decorate(string, :red)).to eq("\e[31mfoo\nbar\nbaz\e[0m")
  end

  it "allows to decorate each line separately" do
    string = "foo\nbar\nbaz"
    color = described_class.new(enabled: true, eachline: "\n")
    expect(color.decorate(string, :red)).to eq([
      "\e[31mfoo\e[0m",
      "\e[31mbar\e[0m",
      "\e[31mbaz\e[0m"
    ].join("\n"))
  end

  it 'errors for unknown color' do
    expect {
      color.decorate(string, :crimson)
    }.to raise_error(Pastel::InvalidAttributeNameError)
  end

  it "doesn't decorate non-string instance" do
    expect(color.decorate({}, :red)).to eq({})
  end

  it "doesn't decorate nil" do
    expect(color.decorate(nil, :red)).to eq(nil)
  end

  it "doesn't decorate zero length string" do
    expect(color.decorate('', :red)).to eq('')
  end

  it "doesn't decorate non-zero length string" do
    expect(color.decorate('  ', :red)).to eq("\e[31m  \e[0m")
  end
end
