# coding: utf-8

require 'spec_helper'

RSpec.describe Stoplight::DataStore::Base do
  let(:data_store) { described_class.new }

  it 'is a class' do
    expect(described_class).to be_a(Class)
  end

  describe '#names' do
    it 'is not implemented' do
      expect { data_store.names }.to raise_error(NotImplementedError)
    end
  end

  describe '#get_all' do
    it 'is not implemented' do
      expect { data_store.get_all(nil) }.to raise_error(NotImplementedError)
    end
  end

  describe '#get_failures' do
    it 'is not implemented' do
      expect { data_store.get_failures(nil) }
        .to raise_error(NotImplementedError)
    end
  end

  describe '#record_failure' do
    it 'is not implemented' do
      expect { data_store.record_failure(nil, nil) }
        .to raise_error(NotImplementedError)
    end
  end

  describe '#clear_failures' do
    it 'is not implemented' do
      expect { data_store.clear_failures(nil) }
        .to raise_error(NotImplementedError)
    end
  end

  describe '#get_state' do
    it 'is not implemented' do
      expect { data_store.get_state(nil) }.to raise_error(NotImplementedError)
    end
  end

  describe '#set_state' do
    it 'is not implemented' do
      expect { data_store.set_state(nil, nil) }
        .to raise_error(NotImplementedError)
    end
  end

  describe '#clear_state' do
    it 'is not implemented' do
      expect { data_store.clear_state(nil) }
        .to raise_error(NotImplementedError)
    end
  end
end
