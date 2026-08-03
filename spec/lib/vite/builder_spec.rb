# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Vite::Builder do
  subject { described_class.new(config:, logger:) }

  let(:config) { Struct.new(:build_command).new('echo "spec builder"') }
  let(:buffer) { StringIO.new }
  let(:logger) { Logger.new(buffer) }

  describe '#build' do
    it 'executes the configured build_command and logs the output' do
      subject.build

      buffer.rewind

      expect(buffer.read).to include('spec builder')
    end
  end

  describe '#build!' do
    context 'when the command fails' do
      let(:config) { Struct.new(:build_command).new('false') }

      it 'raises an error' do
        expect { subject.build! }.to raise_error(Vite::Builder::BuildError)
      end
    end
  end
end
