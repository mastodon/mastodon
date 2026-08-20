# frozen_string_literal: true

require 'rails_helper'

RSpec.describe StoplightRegistry do
  subject { described_class }

  describe '.fetch' do
    it 'creates a new light' do
      name =  "test-#{rand}"
      light = subject.fetch(name)

      expect(light.name).to eq(name)
    end

    it 'reuses an existing light' do
      name =  "test-#{rand}"
      first = subject.fetch(name)
      second = subject.fetch(name)

      expect(first).to be(second)
    end
  end
end
