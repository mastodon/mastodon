# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Security Enhancements', type: :request do
  describe 'Session Cookie Security' do
    it 'sets secure flag on cookies in production environment' do
      allow(Rails.env).to receive(:production?).and_return(true)
      
      post '/auth/sign_in', params: {
        user: { email: 'test@example.com', password: 'password123' }
      }
      
      session_cookie = response.cookies['_mastodon_session']
      expect(session_cookie).to include('secure')
    end

    it 'sets httponly flag on session cookies' do
      post '/auth/sign_in', params: {
        user: { email: 'test@example.com', password: 'password123' }
      }
      
      session_cookie = response.cookies['_mastodon_session']
      expect(session_cookie).to include('HttpOnly')
    end
  end

  describe 'CSRF Protection' do
    it 'requires CSRF token for state-changing requests' do
      post '/auth/sign_in', params: {
        user: { email: 'test@example.com', password: 'password123' }
      }
      
      expect(response).to have_http_status(:unprocessable_entity)
    end

    it 'logs CSRF failures for monitoring' do
      expect(Rails.logger).to receive(:warn).with(/CSRF token verification failed/)
      
      post '/auth/sign_in', params: {
        user: { email: 'test@example.com', password: 'password123' }
      }
    end
  end

  describe 'Security Headers' do
    before { get '/' }

    it 'includes X-Frame-Options header' do
      expect(response.headers['X-Frame-Options']).to eq('DENY')
    end

    it 'includes X-Content-Type-Options header' do
      expect(response.headers['X-Content-Type-Options']).to eq('nosniff')
    end

    it 'includes X-XSS-Protection header' do
      expect(response.headers['X-XSS-Protection']).to eq('1; mode=block')
    end

    it 'includes Referrer-Policy header' do
      expect(response.headers['Referrer-Policy']).to eq('strict-origin-when-cross-origin')
    end

    it 'includes Content-Security-Policy header' do
      expect(response.headers['Content-Security-Policy']).to be_present
    end

    context 'in production environment' do
      before do
        allow(Rails.env).to receive(:production?).and_return(true)
        get '/'
      end

      it 'includes HSTS header' do
        expect(response.headers['Strict-Transport-Security']).to include('max-age=31536000')
      end
    end
  end

  describe 'Rate Limiting' do
    let(:user) { Fabricate(:user) }

    it 'limits login attempts per IP' do
      26.times do
        post '/auth/sign_in', params: {
          user: { email: user.email, password: 'wrongpassword' }
        }, headers: { 'REMOTE_ADDR' => '192.168.1.1' }
      end
      
      expect(response).to have_http_status(:too_many_requests)
    end

    it 'limits API requests per token' do
      token = Fabricate(:accessible_access_token, scopes: 'read')
      
      301.times do
        get '/api/v1/accounts/verify_credentials', headers: {
          'Authorization' => "Bearer #{token.token}"
        }
      end
      
      expect(response).to have_http_status(:too_many_requests)
    end
  end

  describe 'Input Validation' do
    describe 'User password validation' do
      it 'requires strong passwords' do
        user = User.new(
          email: 'test@example.com',
          password: 'weak',
          account: Fabricate.build(:account)
        )
        
        expect(user).to_not be_valid
        expect(user.errors[:password]).to include('must be at least 12 characters long')
      end

      it 'rejects common passwords' do
        user = User.new(
          email: 'test@example.com',
          password: 'password123',
          account: Fabricate.build(:account)
        )
        
        expect(user).to_not be_valid
        expect(user.errors[:password]).to include('cannot contain common password patterns')
      end
    end

    describe 'Account validation' do
      it 'prevents malicious display names' do
        account = Account.new(
          username: 'testuser',
          display_name: '<script>alert("xss")</script>'
        )
        
        expect(account).to_not be_valid
        expect(account.errors[:display_name]).to include('contains potentially malicious content')
      end

      it 'prevents admin-like usernames' do
        account = Account.new(
          username: 'administrator',
          domain: nil
        )
        
        expect(account).to_not be_valid
        expect(account.errors[:username]).to include('cannot contain administrative terms')
      end
    end
  end
end
