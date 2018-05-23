require 'spec_helper'

RSpec.describe ROTP::HOTP do
  let(:counter) { 1234 }
  let(:token)   { '161024' }
  let(:hotp)    { ROTP::HOTP.new('a' * 32) }

  describe '#at' do
    let(:token) { hotp.at counter }

    context 'only the counter as argument' do
      it 'generates a string OTP' do
        expect(token).to eq '161024'
      end
    end

    context 'without padding' do
      let(:token) { hotp.at counter, false }

      it 'generates an integer OTP' do
        expect(token).to eq 161024
      end
    end

    context 'RFC compatibility' do
      let(:hotp) { ROTP::HOTP.new('GEZDGNBVGY3TQOJQGEZDGNBVGY3TQOJQ') }

      it 'matches the RFC documentation examples' do
        # 12345678901234567890 in Base32
        # GEZDGNBVGY3TQOJQGEZDGNBVGY3TQOJQ
        expect(hotp.at(0)).to eq '755224'
        expect(hotp.at(1)).to eq '287082'
        expect(hotp.at(2)).to eq '359152'
        expect(hotp.at(3)).to eq '969429'
        expect(hotp.at(4)).to eq '338314'
        expect(hotp.at(5)).to eq '254676'
        expect(hotp.at(6)).to eq '287922'
        expect(hotp.at(7)).to eq '162583'
        expect(hotp.at(8)).to eq '399871'
        expect(hotp.at(9)).to eq '520489'
      end

    end
  end

  describe '#verify' do
    let(:verification) { hotp.verify token, counter }

    context 'numeric token' do
      let(:token) { 161024 }

      it 'raises an error' do
        expect { verification }.to raise_error
      end
    end

    context 'string token' do
      it 'is true' do
        expect(verification).to be_truthy
      end
    end

    context 'RFC compatibility' do
      let(:hotp)  { ROTP::HOTP.new('GEZDGNBVGY3TQOJQGEZDGNBVGY3TQOJQ') }
      let(:token) { '520489' }

      it 'verifies and does not allow reuse' do
        expect(hotp.verify(token, 9)).to be_truthy
        expect(hotp.verify(token, 10)).to be_falsey
      end
    end
  end

  describe '#provisioning_uri' do
    let(:uri)    { hotp.provisioning_uri('mark@percival') }
    let(:params) { CGI::parse URI::parse(uri).query }

    it 'has the correct format' do
      expect(uri).to match %r{\Aotpauth:\/\/hotp.+}
    end

    it 'includes the secret as parameter' do
      expect(params['secret'].first).to eq 'a' * 32
    end
  end

  describe '#verify_with_retries' do
    let(:verification) { hotp.verify_with_retries token, counter, retries }

    context 'negative retries' do
      let(:retries) { -1 }

      it 'is false' do
        expect(verification).to be_falsey
      end
    end

    context 'zero retries' do
      let(:retries) { 0 }

      it 'is false' do
        expect(verification).to be_falsey
      end
    end

    context 'counter lower than retries' do
      let(:counter) { 1223 }
      let(:retries) { 10 }

      it 'is false' do
        expect(verification).to be_falsey
      end
    end

    context 'counter exactly in retry range' do
      let(:counter) { 1224 }
      let(:retries) { 10 }

      it 'is true' do
        expect(verification).to eq 1234
      end
    end

    context 'counter in retry range' do
      let(:counter) { 1224 }
      let(:retries) { 11 }

      it 'is true' do
        expect(verification).to eq 1234
      end
    end

    context 'counter too high' do
      let(:counter) { 1235 }
      let(:retries) { 3 }

      it 'is false' do
        expect(verification).to be_falsey
      end
    end
  end
end
