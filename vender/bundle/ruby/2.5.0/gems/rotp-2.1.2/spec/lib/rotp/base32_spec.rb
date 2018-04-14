require 'spec_helper'

RSpec.describe ROTP::Base32 do

  describe '.random_base32' do
    context 'without arguments' do
      let(:base32) { ROTP::Base32.random_base32 }

      it 'is 16 characters long' do
        expect(base32.length).to eq 16
      end

      it 'is hexadecimal' do
        expect(base32).to match %r{\A[a-z2-7]+\z}
      end
    end

    context 'with arguments' do
      let(:base32) { ROTP::Base32.random_base32 32 }

      it 'allows a specific length' do
        expect(base32.length).to eq 32
      end
    end
  end

  describe '.decode' do
    context 'corrupt input data' do
      it 'raises a sane error' do
        expect { ROTP::Base32.decode('4BCDEFG234BCDEF1') }.to \
          raise_error(ROTP::Base32::Base32Error, "Invalid Base32 Character - '1'")
      end
    end

    context 'valid input data' do
      it 'correctly decodes a string' do
        expect(ROTP::Base32.decode('F').unpack('H*').first).to eq '28'
        expect(ROTP::Base32.decode('23').unpack('H*').first).to eq 'd6'
        expect(ROTP::Base32.decode('234').unpack('H*').first).to eq 'd6f8'
        expect(ROTP::Base32.decode('234A').unpack('H*').first).to eq 'd6f800'
        expect(ROTP::Base32.decode('234B').unpack('H*').first).to eq 'd6f810'
        expect(ROTP::Base32.decode('234BCD').unpack('H*').first).to eq 'd6f8110c'
        expect(ROTP::Base32.decode('234BCDE').unpack('H*').first).to eq 'd6f8110c80'
        expect(ROTP::Base32.decode('234BCDEFG').unpack('H*').first).to eq 'd6f8110c8530'
        expect(ROTP::Base32.decode('234BCDEFG234BCDEFG').unpack('H*').first).to eq 'd6f8110c8536b7c0886429'
      end
    end
  end
end
