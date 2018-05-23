# coding: utf-8

require 'spec_helper'
require 'stringio'

RSpec.describe Stoplight::Light do
  let(:light) { described_class.new(name, &code) }
  let(:name) { ('a'..'z').to_a.shuffle.join }
  let(:code) { -> {} }

  it 'is a class' do
    expect(described_class).to be_a(Class)
  end

  describe '.default_data_store' do
    it 'is initially the default' do
      expect(described_class.default_data_store)
        .to eql(Stoplight::Default::DATA_STORE)
    end
  end

  describe '.default_data_store=' do
    before { @default_data_store = described_class.default_data_store }
    after { described_class.default_data_store = @default_data_store }

    it 'sets the data store' do
      data_store = Stoplight::DataStore::Memory.new
      described_class.default_data_store = data_store
      expect(described_class.default_data_store).to eql(data_store)
    end
  end

  describe '.default_error_notifier' do
    it 'is initially the default' do
      expect(described_class.default_error_notifier)
        .to eql(Stoplight::Default::ERROR_NOTIFIER)
    end
  end

  describe '.default_error_notifier=' do
    before { @default_error_notifier = described_class.default_error_notifier }
    after { described_class.default_error_notifier = @default_error_notifier }

    it 'sets the error notifier' do
      default_error_notifier = -> (_) {}
      described_class.default_error_notifier = default_error_notifier
      expect(described_class.default_error_notifier)
        .to eql(default_error_notifier)
    end
  end

  describe '.default_notifiers' do
    it 'is initially the default' do
      expect(described_class.default_notifiers)
        .to eql(Stoplight::Default::NOTIFIERS)
    end
  end

  describe '.default_notifiers=' do
    before { @default_notifiers = described_class.default_notifiers }
    after { described_class.default_notifiers = @default_notifiers }

    it 'sets the data store' do
      notifiers = []
      described_class.default_notifiers = notifiers
      expect(described_class.default_notifiers).to eql(notifiers)
    end
  end

  describe '#code' do
    it 'reads the code' do
      expect(light.code).to eql(code)
    end
  end

  describe '#cool_off_time' do
    it 'is initially the default' do
      expect(light.cool_off_time).to eql(Stoplight::Default::COOL_OFF_TIME)
    end
  end

  describe '#data_store' do
    it 'is initially the default' do
      expect(light.data_store).to eql(described_class.default_data_store)
    end
  end

  describe '#error_handler' do
    it 'it initially the default' do
      expect(light.error_handler).to eql(Stoplight::Default::ERROR_HANDLER)
    end
  end

  describe '#error_notifier' do
    it 'it initially the default' do
      expect(light.error_notifier)
        .to eql(described_class.default_error_notifier)
    end
  end

  describe '#fallback' do
    it 'is initially the default' do
      expect(light.fallback).to eql(Stoplight::Default::FALLBACK)
    end
  end

  describe '#name' do
    it 'reads the name' do
      expect(light.name).to eql(name)
    end
  end

  describe '#notifiers' do
    it 'is initially the default' do
      expect(light.notifiers).to eql(described_class.default_notifiers)
    end
  end

  describe '#threshold' do
    it 'is initially the default' do
      expect(light.threshold).to eql(Stoplight::Default::THRESHOLD)
    end
  end

  describe '#with_cool_off_time' do
    it 'sets the cool off time' do
      cool_off_time = 1.2
      light.with_cool_off_time(cool_off_time)
      expect(light.cool_off_time).to eql(cool_off_time)
    end
  end

  describe '#with_data_store' do
    it 'sets the data store' do
      data_store = Stoplight::DataStore::Memory.new
      light.with_data_store(data_store)
      expect(light.data_store).to eql(data_store)
    end
  end

  describe '#with_error_handler' do
    it 'sets the error handler' do
      error_handler = -> (_, _) {}
      light.with_error_handler(&error_handler)
      expect(light.error_handler).to eql(error_handler)
    end
  end

  describe '#with_error_notifier' do
    it 'sets the error notifier' do
      error_notifier = -> (_) {}
      light.with_error_notifier(&error_notifier)
      expect(light.error_notifier).to eql(error_notifier)
    end
  end

  describe '#with_fallback' do
    it 'sets the fallback' do
      fallback = -> (_) {}
      light.with_fallback(&fallback)
      expect(light.fallback).to eql(fallback)
    end
  end

  describe '#with_notifiers' do
    it 'sets the notifiers' do
      notifiers = [Stoplight::Notifier::IO.new(StringIO.new)]
      light.with_notifiers(notifiers)
      expect(light.notifiers).to eql(notifiers)
    end
  end

  describe '#with_threshold' do
    it 'sets the threshold' do
      threshold = 12
      light.with_threshold(threshold)
      expect(light.threshold).to eql(threshold)
    end
  end
end
