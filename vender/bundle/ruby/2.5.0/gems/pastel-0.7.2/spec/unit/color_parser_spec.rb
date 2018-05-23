# encoding: utf-8

RSpec.describe Pastel::ColorParser, '::parse' do
  subject(:parser) { described_class }

  it "parses string with no color" do
    expect(parser.parse("foo")).to eq([{text: 'foo'}])
  end

  it "parses simple color" do
    expect(parser.parse("\e[32mfoo\e[0m")).to eq([
     {foreground: :green, text: 'foo'}
    ])
  end

  it "parses simple color and style" do
    expect(parser.parse("\e[32;1mfoo\e[0m")).to eq([
      {foreground: :green, style: :bold, text: 'foo'}
    ])
  end

  it "parses chained colors in shorthand syntax" do
    expect(parser.parse("\e[32;44mfoo\e[0m")).to eq([
      {foreground: :green, background: :on_blue, text: 'foo'}
    ])
  end

  it "parses chained colors in regular syntax" do
    expect(parser.parse("\e[32m\e[44mfoo\e[0m")).to eq([
      {foreground: :green, background: :on_blue, text: 'foo'}
    ])
  end

  it "parses many colors" do
    expect(parser.parse("\e[32mfoo\e[0m \e[31mbar\e[0m")).to eq([
      {foreground: :green, text: 'foo'},
      {text: ' '},
      {foreground: :red, text: 'bar'}
    ])
  end

  it "parses nested colors with one reset" do
    expect(parser.parse("\e[32mfoo\e[31mbar\e[0m")).to eq([
      {foreground: :green, text: 'foo'},
      {foreground: :red, text: 'bar'}
    ])
  end

  it "parses nested colors with two resets" do
    expect(parser.parse("\e[32mfoo\e[31mbar\e[0m\e[0m")).to eq([
      {foreground: :green, text: 'foo'},
      {foreground: :red, text: 'bar'}
    ])
  end

  it "parses unrest color" do
    expect(parser.parse("\e[32mfoo")).to eq([
      {foreground: :green, text: 'foo'}
    ])
  end

  it "parses malformed control sequence" do
    expect(parser.parse("\eA foo bar ESC\e")).to eq([
      {text: "\eA foo bar ESC\e"}
    ])
  end
end
