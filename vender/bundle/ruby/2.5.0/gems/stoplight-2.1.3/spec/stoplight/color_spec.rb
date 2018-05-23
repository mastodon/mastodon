# coding: utf-8

require 'spec_helper'

RSpec.describe Stoplight::Color do
  it 'is a module' do
    expect(described_class).to be_a(Module)
  end

  describe '::GREEN' do
    it 'is a string' do
      expect(Stoplight::Color::GREEN).to be_a(String)
    end

    it 'is frozen' do
      expect(Stoplight::Color::GREEN).to be_frozen
    end
  end

  describe '::YELLOW' do
    it 'is a string' do
      expect(Stoplight::Color::YELLOW).to be_a(String)
    end

    it 'is frozen' do
      expect(Stoplight::Color::YELLOW).to be_frozen
    end
  end

  describe '::RED' do
    it 'is a string' do
      expect(Stoplight::Color::RED).to be_a(String)
    end

    it 'is frozen' do
      expect(Stoplight::Color::RED).to be_frozen
    end
  end
end
