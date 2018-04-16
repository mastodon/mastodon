# coding: utf-8

require 'spec_helper'

RSpec.describe Stoplight::Notifier::Base do
  let(:notifier) { described_class.new }

  it 'is a class' do
    expect(described_class).to be_a(Class)
  end

  describe '#notify' do
    it 'is not implemented' do
      expect { notifier.notify(nil, nil, nil, nil) }
        .to raise_error(NotImplementedError)
    end
  end
end
