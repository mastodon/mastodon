# coding: utf-8

require 'spec_helper'

# require 'slack-notifier'
module Slack
  class Notifier
    def initialize(*)
    end
  end
end

RSpec.describe Stoplight::Notifier::Slack do
  it_behaves_like 'a generic notifier'

  it 'is a class' do
    expect(described_class).to be_a(Class)
  end

  it 'is a subclass of Base' do
    expect(described_class).to be < Stoplight::Notifier::Base
  end

  describe '#slack' do
    it 'reads Slack::Notifier client' do
      slack = Slack::Notifier.new('WEBHOOK_URL')
      expect(described_class.new(slack).slack).to eql(slack)
    end
  end

  describe '#notify' do
    let(:light) { Stoplight::Light.new(name, &code) }
    let(:name) { ('a'..'z').to_a.shuffle.join }
    let(:code) { -> {} }
    let(:from_color) { Stoplight::Color::GREEN }
    let(:to_color) { Stoplight::Color::RED }
    let(:notifier) { described_class.new(slack) }
    let(:slack) { double(Slack::Notifier).as_null_object }

    it 'pings Slack' do
      error = nil
      message = notifier.formatter.call(light, from_color, to_color, error)
      expect(slack).to receive(:ping).with(message)
      notifier.notify(light, from_color, to_color, error)
    end
  end
end
