# coding: utf-8

require 'spec_helper'

RSpec.shared_examples_for 'a generic notifier' do
  it 'includes Generic' do
    expect(described_class).to include(Stoplight::Notifier::Generic)
  end

  describe '#formatter' do
    it 'is initially the default' do
      formatter = nil
      expect(described_class.new(nil, formatter).formatter)
        .to eql(Stoplight::Default::FORMATTER)
    end

    it 'reads the formatter' do
      formatter = proc {}
      expect(described_class.new(nil, formatter).formatter)
        .to eql(formatter)
    end
  end

  describe '#notify' do
    let(:light) { Stoplight::Light.new(name, &code) }
    let(:name) { ('a'..'z').to_a.shuffle.join }
    let(:code) { -> {} }
    let(:from_color) { Stoplight::Color::GREEN }
    let(:to_color) { Stoplight::Color::RED }
    let(:notifier) { described_class.new(double.as_null_object) }

    it 'returns the message' do
      error = nil
      expect(notifier.notify(light, from_color, to_color, error))
        .to eql(notifier.formatter.call(light, from_color, to_color, error))
    end

    it 'returns the message with an error' do
      error = ZeroDivisionError.new('divided by 0')
      expect(notifier.notify(light, from_color, to_color, error))
        .to eql(notifier.formatter.call(light, from_color, to_color, error))
    end
  end
end

RSpec.describe Stoplight::Notifier::Generic do
  it 'is a module' do
    expect(described_class).to be_a(Module)
  end
end
