# encoding: utf-8

RSpec.describe Necromancer, '.convert' do

  subject(:converter) { described_class.new }

  it "indicates inability to perform the requested conversion" do
    expect {
      converter.convert(:foo).to(:float)
    }.to raise_error(Necromancer::NoTypeConversionAvailableError,
                     /Conversion 'symbol->float' unavailable/)
  end

  it "allows for module level convert call" do
    expect(Necromancer.convert('1,2,3').to(:array)).to eq([1,2,3])
  end

  it "allows replacing #to with #>> call" do
    expect(converter.convert('1,2,3') >> :array).to eq([1,2,3])
  end

  it "allows to specify object as conversion target" do
    expect(converter.convert('1,2,3') >> []).to eq([1,2,3])
  end

  it "allows to specify class as conversion target" do
    expect(converter.convert('1,2,3') >> Array).to eq([1,2,3])
  end

  context 'when array' do
    it "converts string to array" do
      expect(converter.convert("1,2,3").to(:array)).to eq([1,2,3])
    end

    it "converts array to numeric " do
      expect(converter.convert(['1','2.3','3.0']).to(:numeric)).to eq([1,2.3,3.0])
    end

    it "converts array to boolean" do
      expect(converter.convert(['t', 'no']).to(:boolean)).to eq([true, false])
    end

    it "converts object to array" do
      expect(converter.convert({x: 1}).to(:array)).to eq([[:x, 1]])
    end

    it "fails to convert in strict mode" do
      expect {
        converter.convert(['1', '2.3', false]).to(:numeric, strict: true)
      }.to raise_error(Necromancer::ConversionTypeError)
    end
  end

  context 'when numeric' do
    it "converts string to integer" do
      expect(converter.convert('1').to(:integer)).to eq(1)
    end

    it "allows for block for conversion method" do
      expect(converter.convert { '1' }.to(:integer)).to eq(1)
    end

    it "convers integer to string" do
      expect(converter.convert(1).to(:string)).to eq('1')
    end

    it "allows for null type conversion" do
      expect(converter.convert(1).to(:integer)).to eq(1)
    end

    it "raises error when in strict mode" do
      expect {
        converter.convert('1a').to(:integer, strict: true)
      }.to raise_error(Necromancer::ConversionTypeError)
    end

    it "doesn't raise error when in non-strict mode" do
      expect(converter.convert('1').to(:integer, strict: false)).to eql(1)
    end

    it "converts string to float" do
      expect(converter.convert('1.0').to(:float)).to eql(1.0)
    end

    it "converts string to numeric" do
      expect(converter.convert('1.0').to(:numeric)).to eql(1.0)
    end
  end

  context 'when boolean' do
    it "converts boolean to boolean" do
      expect(converter.convert(true).to(:boolean)).to eq(true)
    end

    it "converts string to boolean" do
      expect(converter.convert('yes').to(:boolean)).to eq(true)
    end

    it "converts integer to boolean" do
      expect(converter.convert(0).to(:boolean)).to eq(false)
    end

    it "converts boolean to integer" do
      expect(converter.convert(true).to(:integer)).to eq(1)
    end
  end

  context 'when range' do
    it "converts string to range" do
      expect(converter.convert('1-10').to(:range)).to eq(1..10)
    end
  end

  context 'when datetime' do
    it "converts string to date" do
      expect(converter.convert('2014-12-07').to(:date)).
        to eq(Date.parse('2014-12-07'))
    end

    it "converts string to datetime" do
      expect(converter.convert('2014-12-07 17:35:44').to(:datetime)).
        to eq(DateTime.parse('2014-12-07 17:35:44'))
    end

    it "converts string to time" do
      expect(converter.convert('12:30').to(:time)).
        to eq(Time.parse('12:30'))
    end
  end
end
