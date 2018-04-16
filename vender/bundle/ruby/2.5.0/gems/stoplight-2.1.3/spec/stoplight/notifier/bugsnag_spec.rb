# coding: utf-8

require 'spec_helper'

# require 'bugsnag'
module Bugsnag
end

RSpec.describe Stoplight::Notifier::Bugsnag do
  StoplightStatusChange = Stoplight::Notifier::Bugsnag::StoplightStatusChange

  it 'is a class' do
    expect(described_class).to be_a(Class)
  end

  it 'is a subclass of Base' do
    expect(described_class).to be < Stoplight::Notifier::Base
  end

  describe '#formatter' do
    it 'is initially the default' do
      expect(described_class.new(nil, nil).formatter)
        .to eql(Stoplight::Default::FORMATTER)
    end

    it 'reads the formatter' do
      formatter = proc {}
      expect(described_class.new(nil, formatter).formatter)
        .to eql(formatter)
    end
  end

  describe '#options' do
    it 'is initially the default' do
      expect(described_class.new(nil, nil).options)
        .to eql(Stoplight::Notifier::Bugsnag::DEFAULT_OPTIONS)
    end

    it 'reads the options' do
      options = { key: :value }
      expect(described_class.new(nil, nil, options).options)
        .to eql(Stoplight::Notifier::Bugsnag::DEFAULT_OPTIONS.merge(options))
    end
  end

  describe '#bugsnag' do
    it 'reads the Bugsnag client' do
      client = Bugsnag
      expect(described_class.new(client, nil).bugsnag)
        .to eql(client)
    end
  end

  describe '#notify' do
    let(:light) { Stoplight::Light.new(name, &code) }
    let(:name) { ('a'..'z').to_a.shuffle.join }
    let(:code) { -> {} }
    let(:from_color) { Stoplight::Color::GREEN }
    let(:to_color) { Stoplight::Color::RED }
    let(:notifier) { described_class.new(bugsnag) }
    let(:bugsnag) { Bugsnag }

    subject(:result) do
      notifier.notify(light, from_color, to_color, error)
    end

    before do
      status_change = StoplightStatusChange.new(message)
      expect(bugsnag).to receive(:notify).with(status_change, severity: 'info')
    end

    context 'when no error given' do
      let(:error) { nil }

      it 'logs message' do
        expect(result).to eq(message)
      end
    end

    context 'when message with an error given' do
      let(:error) { ZeroDivisionError.new('divided by 0') }

      it 'logs message' do
        expect(result).to eq(message)
      end
    end

    def message
      notifier.formatter.call(light, from_color, to_color, error)
    end
  end
end
