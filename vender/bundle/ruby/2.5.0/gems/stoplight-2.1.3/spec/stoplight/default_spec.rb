# coding: utf-8

require 'spec_helper'

RSpec.describe Stoplight::Default do
  it 'is a module' do
    expect(described_class).to be_a(Module)
  end

  describe '::COOL_OFF_TIME' do
    it 'is a float' do
      expect(Stoplight::Default::COOL_OFF_TIME).to be_a(Float)
    end
  end

  describe '::DATA_STORE' do
    it 'is a data store' do
      expect(Stoplight::Default::DATA_STORE).to be_a(Stoplight::DataStore::Base)
    end
  end

  describe '::ERROR_HANDLER' do
    it 'is a proc' do
      expect(Stoplight::Default::ERROR_HANDLER).to be_a(Proc)
    end

    it 'has an arity of 2' do
      expect(Stoplight::Default::ERROR_HANDLER.arity).to eql(2)
    end
  end

  describe '::ERROR_NOTIFIER' do
    it 'is a proc' do
      expect(Stoplight::Default::ERROR_NOTIFIER).to be_a(Proc)
    end

    it 'has an arity of 1' do
      expect(Stoplight::Default::ERROR_NOTIFIER.arity).to eql(1)
    end
  end

  describe '::FALLBACK' do
    it 'is nil' do
      expect(Stoplight::Default::FALLBACK).to eql(nil)
    end
  end

  describe '::FORMATTER' do
    it 'is a proc' do
      expect(Stoplight::Default::FORMATTER).to be_a(Proc)
    end

    it 'has the same arity as #notify' do
      notify = Stoplight::Notifier::Base.new.method(:notify)
      expect(Stoplight::Default::FORMATTER.arity).to eql(notify.arity)
    end
  end

  describe '::NOTIFIERS' do
    it 'is an array' do
      expect(Stoplight::Default::NOTIFIERS).to be_an(Array)
    end

    it 'contains notifiers' do
      Stoplight::Default::NOTIFIERS.each do |notifier|
        expect(notifier).to be_a(Stoplight::Notifier::Base)
      end
    end

    it 'is frozen' do
      expect(Stoplight::Default::NOTIFIERS).to be_frozen
    end
  end

  describe '::THRESHOLD' do
    it 'is an integer' do
      expect(Stoplight::Default::THRESHOLD).to be_a(Fixnum)
    end
  end
end
