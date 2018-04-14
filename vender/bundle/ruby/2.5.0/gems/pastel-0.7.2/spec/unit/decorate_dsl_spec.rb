# encoding: utf-8

RSpec.describe Pastel, 'coloring dsl' do

  subject(:pastel) { described_class.new(enabled: true) }

  it "colors string" do
    expect(pastel.red("unicorn")).to eq("\e[31municorn\e[0m")
  end

  it "allows to specify variable number of arguments" do
    expect(pastel.red("unicorn", "running")).to eq("\e[31municornrunning\e[0m")
  end

  it "combines colored strings with regular ones" do
    expect(pastel.red("Unicorns") + ' will rule ' + pastel.green('the World!')).
      to eq("\e[31mUnicorns\e[0m will rule \e[32mthe World!\e[0m")
  end

  it "composes two color strings " do
    expect(pastel.red.on_green("unicorn")).to eq("\e[31;42municorn\e[0m")
  end

  it "composes three color strings" do
    expect(pastel.red.on_green.underline("unicorn")).
      to eq("\e[31;42;4municorn\e[0m")
  end

  it "combines colored composed strings with regular ones" do
    expect(pastel.red.on_green("Unicorns") + ' will rule ' +
      pastel.green.on_red('the World!')).
    to eq("\e[31;42mUnicorns\e[0m will rule \e[32;41mthe World!\e[0m")
  end

  it "allows one level nesting" do
    expect(pastel.red("Unicorn" + pastel.blue("rule!"))).
      to eq("\e[31mUnicorn\e[34mrule!\e[0m\e[0m")
  end

  it "allows to nest mixed styles" do
    expect(pastel.red("Unicorn" + pastel.green.on_yellow.underline('running') + '!')).
      to eq("\e[31mUnicorn\e[32;43;4mrunning\e[0m\e[31m!\e[0m")
  end

  it "allows for deep nesting" do
    expect(pastel.red('r' + pastel.green('g' + pastel.yellow('y') + 'g') + 'r')).
      to eq("\e[31mr\e[32mg\e[33my\e[0m\e[32mg\e[0m\e[31mr\e[0m")
  end

  it "allows for variable nested arguments" do
    expect(pastel.red('r', pastel.green('g'), 'r')).
      to eq("\e[31mr\e[32mg\e[0m\e[31mr\e[0m")
  end

  it "nests color foreground & background" do
    expect(pastel.on_red('foo', pastel.green('bar'), 'foo')).
      to eq("\e[41mfoo\e[32mbar\e[0m\e[41mfoo\e[0m")
  end

  it "allows to nest styles within block" do
    string = pastel.red.on_green('Unicorns' +
      pastel.green.on_red('will ', 'dominate' + pastel.yellow('the world!')))

    expect(pastel.red.on_green('Unicorns') do
      green.on_red('will ', 'dominate') do
        yellow('the world!')
      end
    end).to eq(string)
  end

  it "doesn't decorate nil" do
    expect(pastel.red(nil)).to eq('')
  end

  it "doesn't apply styles to empty string" do
    expect(pastel.red('')).to eq('')
  end

  it "applies styles to empty with width more than 1" do
    expect(pastel.red(' ')).to eq("\e[31m \e[0m")
  end

  it "applies color only once" do
    expect(pastel.red.red.red("unicorn")).to eq(pastel.red("unicorn"))
  end

  it "raises error when chained with unrecognized color" do
    expect {
      pastel.unknown.on_red('unicorn')
    }.to raise_error(Pastel::InvalidAttributeNameError)
  end

  it "raises error when doesn't recognize color" do
    expect {
      pastel.unknown('unicorn')
    }.to raise_error(Pastel::InvalidAttributeNameError)
  end
end
