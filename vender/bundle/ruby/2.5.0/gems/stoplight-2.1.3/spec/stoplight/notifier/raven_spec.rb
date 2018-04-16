# coding: utf-8

require 'spec_helper'

# require 'sentry-raven'
module Raven
  class Configuration
  end
end

RSpec.describe Stoplight::Notifier::Raven do
  it 'is a class' do
    expect(described_class).to be_a(Class)
  end

  it 'is a subclass of Base' do
    expect(described_class).to be < Stoplight::Notifier::Base
  end

  describe '#formatter' do
    it 'is initially the default' do
      expect(described_class.new(nil).formatter).to eql(
        Stoplight::Default::FORMATTER
      )
    end

    it 'reads the formatter' do
      formatter = proc {}
      expect(described_class.new(nil, formatter).formatter).to eql(formatter)
    end
  end

  describe '#options' do
    it 'is initially the default' do
      expect(described_class.new(nil).options).to eql(
        Stoplight::Notifier::Raven::DEFAULT_OPTIONS
      )
    end

    it 'reads the options' do
      options = { key: :value }
      expect(described_class.new(nil, nil, options).options).to eql(
        Stoplight::Notifier::Raven::DEFAULT_OPTIONS.merge(options)
      )
    end
  end

  describe '#notify' do
    let(:light) { Stoplight::Light.new(name, &code) }
    let(:name) { ('a'..'z').to_a.shuffle.join }
    let(:code) { -> {} }
    let(:from_color) { Stoplight::Color::GREEN }
    let(:to_color) { Stoplight::Color::RED }
    let(:notifier) { described_class.new(configuration) }
    let(:configuration) { instance_double(::Raven::Configuration) }

    before do
      allow(::Raven).to receive(:capture_message)
    end

    it 'returns the message' do
      error = nil
      message = notifier.formatter.call(light, from_color, to_color, error)
      expect(notifier.notify(light, from_color, to_color, error)).to eql(
        message
      )
      expect(::Raven).to have_received(:capture_message).with(
        message,
        hash_including(
          configuration: configuration
        )
      )
    end

    it 'returns the message with an error' do
      error = ZeroDivisionError.new('divided by 0')
      message = notifier.formatter.call(light, from_color, to_color, error)
      expect(notifier.notify(light, from_color, to_color, error)).to eql(
        message
      )
      expect(::Raven).to have_received(:capture_message).with(
        message,
        hash_including(
          configuration: configuration,
          backtrace: error.backtrace
        )
      )
    end
  end
end
