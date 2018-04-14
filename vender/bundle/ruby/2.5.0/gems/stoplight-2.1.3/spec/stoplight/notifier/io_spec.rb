# coding: utf-8

require 'spec_helper'
require 'stringio'

RSpec.describe Stoplight::Notifier::IO do
  it_behaves_like 'a generic notifier'

  it 'is a class' do
    expect(described_class).to be_a(Class)
  end

  it 'is a subclass of Base' do
    expect(described_class).to be < Stoplight::Notifier::Base
  end

  describe '#io' do
    it 'reads the IO' do
      io = StringIO.new
      expect(described_class.new(io).io).to eql(io)
    end
  end

  describe '#notify' do
    let(:light) { Stoplight::Light.new(name, &code) }
    let(:name) { ('a'..'z').to_a.shuffle.join }
    let(:code) { -> {} }
    let(:from_color) { Stoplight::Color::GREEN }
    let(:to_color) { Stoplight::Color::RED }
    let(:notifier) { described_class.new(io) }
    let(:io) { StringIO.new }

    it 'writes the message' do
      error = nil
      notifier.notify(light, from_color, to_color, error)
      message = notifier.formatter.call(light, from_color, to_color, error)
      expect(io.string).to eql("#{message}\n")
    end
  end
end
