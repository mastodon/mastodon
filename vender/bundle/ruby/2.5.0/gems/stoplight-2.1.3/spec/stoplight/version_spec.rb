# coding: utf-8

require 'spec_helper'

RSpec.describe Stoplight::VERSION do
  it 'is a gem version' do
    expect(described_class).to be_a(Gem::Version)
  end
end
