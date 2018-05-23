# encoding: utf-8

RSpec.describe Pastel, '#new' do

  subject(:pastel) { described_class.new(enabled: true) }

  it { is_expected.to respond_to(:lookup) }

  it { is_expected.to respond_to(:decorate) }

  it { is_expected.to respond_to(:undecorate) }

  it { is_expected.to respond_to(:strip) }

  describe '#valid?' do
    it "when valid returns true" do
      expect(pastel.valid?(:red)).to eq(true)
    end

    it "returns false when invalid" do
      expect(pastel.valid?(:unknown)).to eq(false)
    end
  end

  describe '#colored?' do
    it "checks if string is colored" do
      expect(pastel.colored?("\e[31mfoo\e[0m")).to eq(true)
    end
  end

  describe 'options passed in' do
    it 'defaults enabled to color detection' do
      allow(TTY::Color).to receive(:color?).and_return(true)
      allow(TTY::Color).to receive(:windows?).and_return(false)

      pastel = described_class.new

      expect(pastel.enabled?).to eq(true)
      expect(TTY::Color).to have_received(:color?)
    end

    it "defaults to enabled on Windows" do
      allow(TTY::Color).to receive(:color?).and_return(false)
      allow(TTY::Color).to receive(:windows?).and_return(true)

      pastel = described_class.new

      expect(pastel.enabled?).to eq(true)
      expect(TTY::Color).to_not have_received(:color?)
    end

    it "sets enabled option" do
      pastel = described_class.new(enabled: false)
      expect(pastel.enabled?).to eq(false)
      expect(pastel.red('Unicorn', pastel.green('!'))).to eq('Unicorn!')
    end

    it "sets eachline option" do
      pastel = described_class.new(enabled: true, eachline: "\n")
      expect(pastel.red("foo\nbar")).to eq("\e[31mfoo\e[0m\n\e[31mbar\e[0m")
    end
  end
end
