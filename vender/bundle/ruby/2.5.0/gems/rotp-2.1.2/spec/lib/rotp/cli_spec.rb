require 'spec_helper'
require 'rotp/cli'

RSpec.describe ROTP::CLI do
  let(:cli)    { described_class.new('executable', argv) }
  let(:output) { cli.output }
  let(:now)    { Time.utc 2012,1,1 }

  before do
    Timecop.freeze now
  end

  context 'generating a TOTP' do
    let(:argv) { %w(--secret JBSWY3DPEHPK3PXP) }

    it 'prints the corresponding token' do
      expect(output).to eq '068212'
    end
  end

  context 'generating a HOTP' do
    let(:argv) { %W(--hmac --secret #{'a' * 32} --counter 1234) }

    it 'prints the corresponding token' do
      expect(output).to eq '161024'
    end
  end

end
