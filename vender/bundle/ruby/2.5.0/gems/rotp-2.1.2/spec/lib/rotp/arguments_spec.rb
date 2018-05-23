require 'spec_helper'
require 'rotp/arguments'

RSpec.describe ROTP::Arguments do
  let(:arguments) { described_class.new filename, argv }
  let(:argv)      { '' }
  let(:filename)  { 'rotp' }
  let(:options)   { arguments.options }

  context 'without options' do
    describe '#help' do
      it 'shows the help text' do
        expect(arguments.to_s).to include 'Usage: '
      end
    end

    describe '#options' do
      it 'has the default options' do
        expect(options.mode).to eq :time
        expect(options.secret).to be_nil
        expect(options.counter).to eq 0
      end
    end
  end

  context 'unknown arguments' do
    let(:argv) { %w(--does-not-exist -xyz) }

    describe '#options' do
      it 'is in help mode' do
        expect(options.mode).to eq :help
      end

      it 'knows about the problem' do
        expect(options.warnings).to include 'invalid option: --does-not-exist'
      end
    end
  end

  context 'no arguments' do
    let(:argv) { [] }

    describe '#options' do
      it 'is in help mode' do
        expect(options.mode).to eq :help
      end
    end
  end

  context 'asking for help' do
    let(:argv) { %w(--help) }

    describe '#options' do
      it 'is in help mode' do
        expect(options.mode).to eq :help
      end
    end
  end

  context 'generating a counter based secret' do
    let(:argv) { %w(--hmac --secret s3same) }

    describe '#options' do
      it 'is in hmac mode' do
        expect(options.mode).to eq :hmac
      end

      it 'knows the secret' do
        expect(options.secret).to eq 's3same'
      end
    end
  end

  context 'generating a time based secret' do
    let(:argv) { %w(--secret s3same) }

    describe '#options' do
      it 'is in time mode' do
        expect(options.mode).to eq :time
      end

      it 'knows the secret' do
        expect(options.secret).to eq 's3same'
      end
    end
  end

end
