require 'spec_helper'
require 'doorkeeper/oauth/token_response'

module Doorkeeper::OAuth
  describe TokenResponse do
    subject { TokenResponse.new(double.as_null_object) }

    it 'includes access token response headers' do
      headers = subject.headers
      expect(headers.fetch('Cache-Control')).to eq('no-store')
      expect(headers.fetch('Pragma')).to eq('no-cache')
    end

    it 'status is ok' do
      expect(subject.status).to eq(:ok)
    end

    describe '.body' do
      let(:access_token) do
        double :access_token,
               token:              'some-token',
               expires_in:         '3600',
               expires_in_seconds: '300',
               scopes_string:      'two scopes',
               refresh_token:      'some-refresh-token',
               token_type:         'bearer',
               created_at:         0
      end

      subject { TokenResponse.new(access_token).body }

      it 'includes :access_token' do
        expect(subject['access_token']).to eq('some-token')
      end

      it 'includes :token_type' do
        expect(subject['token_type']).to eq('bearer')
      end

      # expires_in_seconds is returned as `expires_in` in order to match
      # the OAuth spec (section 4.2.2)
      it 'includes :expires_in' do
        expect(subject['expires_in']).to eq('300')
      end

      it 'includes :scope' do
        expect(subject['scope']).to eq('two scopes')
      end

      it 'includes :refresh_token' do
        expect(subject['refresh_token']).to eq('some-refresh-token')
      end

      it 'includes :created_at' do
        expect(subject['created_at']).to eq(0)
      end
    end

    describe '.body filters out empty values' do
      let(:access_token) do
        double :access_token,
               token:              'some-token',
               expires_in_seconds: '',
               scopes_string:      '',
               refresh_token:      '',
               token_type:         'bearer',
               created_at:         0
      end

      subject { TokenResponse.new(access_token).body }

      it 'includes :expires_in' do
        expect(subject['expires_in']).to be_nil
      end

      it 'includes :scope' do
        expect(subject['scope']).to be_nil
      end

      it 'includes :refresh_token' do
        expect(subject['refresh_token']).to be_nil
      end
    end
  end
end
