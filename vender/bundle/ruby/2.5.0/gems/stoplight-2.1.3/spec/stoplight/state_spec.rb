# coding: utf-8

require 'spec_helper'

RSpec.describe Stoplight::State do
  it 'is a module' do
    expect(described_class).to be_a(Module)
  end

  describe '::UNLOCKED' do
    it 'is a string' do
      expect(Stoplight::State::UNLOCKED).to be_a(String)
    end

    it 'is frozen' do
      expect(Stoplight::State::UNLOCKED).to be_frozen
    end
  end

  describe '::LOCKED_GREEN' do
    it 'is a string' do
      expect(Stoplight::State::LOCKED_GREEN).to be_a(String)
    end

    it 'is frozen' do
      expect(Stoplight::State::LOCKED_GREEN).to be_frozen
    end
  end

  describe '::LOCKED_RED' do
    it 'is a string' do
      expect(Stoplight::State::LOCKED_RED).to be_a(String)
    end

    it 'is frozen' do
      expect(Stoplight::State::LOCKED_RED).to be_frozen
    end
  end
end
