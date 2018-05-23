# encoding: utf-8

RSpec.describe Pastel::Color, '.strip' do

  subject(:color) { described_class.new(enabled: true) }

  it 'strips ansi color from string' do
    string = "This is a \e[1m\e[34mbold blue text\e[0m"
    expect(color.strip(string)).to eq('This is a bold blue text')
  end

  it "strips partial ansi color" do
    string = "foo\e[1mbar"
    expect(color.strip(string)).to eq('foobar')
  end

  it 'preserves movement characters' do
    # [176A - move cursor up n lines
    expect(color.strip("foo\e[176Abar")).to eq("foo\e[176Abar")
  end

  it 'strips reset/setfg/setbg/italics/strike/underline sequence' do
    string = "\x1b[0;33;49;3;9;4mfoo\x1b[0m"
    expect(color.strip(string)).to eq("foo")
  end

  it 'strips octal in encapsulating brackets' do
    string = "\[\033[01;32m\]u@h \[\033[01;34m\]W $ \[\033[00m\]"
    expect(color.strip(string)).to eq('[]u@h []W $ []')
  end

  it 'strips octal codes without brackets' do
    string = "\033[01;32mu@h \033[01;34mW $ \033[00m"
    expect(color.strip(string)).to eq('u@h W $ ')
  end

  it 'strips octal with multiple colors' do
    string = "\e[3;0;0;mfoo\e[8;50;0m"
    expect(color.strip(string)).to eq('foo')
  end

  it "strips multiple colors delimited by :" do
    string = "\e[31:44:4mfoo\e[0m"
    expect(color.strip(string)).to eq('foo')
  end

  it 'strips control codes' do
    string = "WARN. \x1b[1m&\x1b[0m ERR. \x1b[7m&\x1b[0m"
    expect(color.strip(string)).to eq('WARN. & ERR. &')
  end

  it 'strips escape bytes' do
    string = "This is a \e[1m\e[34mbold blue text\e[0m"
    expect(color.strip(string)).to eq("This is a bold blue text")
  end
end
