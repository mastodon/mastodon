RSpec.shared_examples 'two_factor_authenticatable' do
  before :each do
    subject.otp_secret = subject.class.generate_otp_secret
    subject.consumed_timestep = nil
  end

  describe 'required_fields' do
    it 'should have the attr_encrypted fields for otp_secret' do
      expect(Devise::Models::TwoFactorAuthenticatable.required_fields(subject.class)).to contain_exactly(:encrypted_otp_secret, :encrypted_otp_secret_iv, :encrypted_otp_secret_salt, :consumed_timestep)
    end
  end

  describe '#otp_secret' do
    it 'should be of the configured length' do
      expect(subject.otp_secret.length).to eq(subject.class.otp_secret_length)
    end

    it 'stores the encrypted otp_secret' do
      expect(subject.encrypted_otp_secret).to_not be_nil
    end

    it 'stores an iv for otp_secret' do
      expect(subject.encrypted_otp_secret_iv).to_not be_nil
    end

    it 'stores a salt for otp_secret' do
      expect(subject.encrypted_otp_secret_salt).to_not be_nil
    end
  end

  describe '#validate_and_consume_otp!' do
    let(:otp_secret) { '2z6hxkdwi3uvrnpn' }

    before :each do
      Timecop.freeze(Time.current)
      subject.otp_secret = otp_secret
    end

    after :each do
      Timecop.return
    end

    context 'with a stored consumed_timestep' do
      context 'given a precisely correct OTP' do
        let(:consumed_otp) { ROTP::TOTP.new(otp_secret).at(Time.now) }

        before do
          subject.validate_and_consume_otp!(consumed_otp)
        end

        it 'fails to validate' do
          expect(subject.validate_and_consume_otp!(consumed_otp)).to be false
        end
      end

      context 'given a previously valid OTP within the allowed drift' do
        let(:consumed_otp) { ROTP::TOTP.new(otp_secret).at(Time.now + subject.class.otp_allowed_drift, true) }

        before do
          subject.validate_and_consume_otp!(consumed_otp)
        end

        it 'fails to validate' do
          expect(subject.validate_and_consume_otp!(consumed_otp)).to be false
        end
      end
    end

    it 'validates a precisely correct OTP' do
      otp = ROTP::TOTP.new(otp_secret).at(Time.now)
      expect(subject.validate_and_consume_otp!(otp)).to be true
    end

    it 'fails a nil OTP value' do
      otp = nil
      expect(subject.validate_and_consume_otp!(otp)).to be false
    end

    it 'validates an OTP within the allowed drift' do
      otp = ROTP::TOTP.new(otp_secret).at(Time.now + subject.class.otp_allowed_drift, true)
      expect(subject.validate_and_consume_otp!(otp)).to be true
    end

    it 'does not validate an OTP above the allowed drift' do
      otp = ROTP::TOTP.new(otp_secret).at(Time.now + subject.class.otp_allowed_drift * 2, true)
      expect(subject.validate_and_consume_otp!(otp)).to be false
    end

    it 'does not validate an OTP below the allowed drift' do
      otp = ROTP::TOTP.new(otp_secret).at(Time.now - subject.class.otp_allowed_drift * 2, true)
      expect(subject.validate_and_consume_otp!(otp)).to be false
    end
  end

  describe '#otp_provisioning_uri' do
    let(:otp_secret_length) { subject.class.otp_secret_length }
    let(:account)           { Faker::Internet.email }
    let(:issuer)            { "Tinfoil" }

    it "should return uri with specified account" do
      expect(subject.otp_provisioning_uri(account)).to match(%r{otpauth://totp/#{account}\?secret=\w{#{otp_secret_length}}})
    end

    it 'should return uri with issuer option' do
      expect(subject.otp_provisioning_uri(account, issuer: issuer)).to match(%r{otpauth://totp/#{account}\?.*secret=\w{#{otp_secret_length}}(&|$)})
      expect(subject.otp_provisioning_uri(account, issuer: issuer)).to match(%r{otpauth://totp/#{account}\?.*issuer=#{issuer}(&|$)})
    end
  end
end
