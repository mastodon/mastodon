# coding: utf-8

require 'spec_helper'

# require 'hipchat'
module HipChat
  class Client
    def initialize(*)
    end
  end
end

RSpec.describe Stoplight::Notifier::HipChat do
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
      expect(described_class.new(nil, nil, formatter).formatter)
        .to eql(formatter)
    end
  end

  describe '#hip_chat' do
    it 'reads the HipChat client' do
      hip_chat = HipChat::Client.new('API token')
      expect(described_class.new(hip_chat, nil).hip_chat)
        .to eql(hip_chat)
    end
  end

  describe '#options' do
    it 'is initially the default' do
      expect(described_class.new(nil, nil).options)
        .to eql(Stoplight::Notifier::HipChat::DEFAULT_OPTIONS)
    end

    it 'reads the options' do
      options = { key: :value }
      expect(described_class.new(nil, nil, nil, options).options)
        .to eql(Stoplight::Notifier::HipChat::DEFAULT_OPTIONS.merge(options))
    end
  end

  describe '#room' do
    it 'reads the room' do
      room = 'Notifications'
      expect(described_class.new(nil, room).room).to eql(room)
    end
  end

  describe '#notify' do
    let(:light) { Stoplight::Light.new(name, &code) }
    let(:name) { ('a'..'z').to_a.shuffle.join }
    let(:code) { -> {} }
    let(:from_color) { Stoplight::Color::GREEN }
    let(:to_color) { Stoplight::Color::RED }
    let(:notifier) { described_class.new(hip_chat, room) }
    let(:hip_chat) { double(HipChat::Client) }
    let(:room) { ('a'..'z').to_a.shuffle.join }

    before do
      tmp = double
      expect(hip_chat).to receive(:[]).with(room).and_return(tmp)
      expect(tmp).to receive(:send)
        .with('Stoplight', kind_of(String), kind_of(Hash)).and_return(true)
    end

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
