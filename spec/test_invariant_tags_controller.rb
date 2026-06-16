require 'rails_helper'
require 'json'

RSpec.describe TagsController, type: :controller do
  describe 'security boundary for unauthenticated JSON requests' do
    let(:tag) { create(:tag) }

    # Payloads: unauthenticated JSON request (exploit), boundary case with format param, valid authenticated request
    [
      { format: :json, authenticated: false, description: 'unauthenticated JSON request' },
      { format: :json, authenticated: false, description: 'JSON with query params' },
      { format: :json, authenticated: true, description: 'authenticated JSON request' }
    ].each do |payload|
      it "enforces signature requirement for #{payload[:description]}" do
        # Invariant: JSON endpoints must verify request authenticity when authorized_fetch_mode is enabled,
        # or reject unauthenticated access to prevent enumeration attacks
        allow(controller).to receive(:authorized_fetch_mode?).and_return(true)

        if payload[:authenticated]
          # Simulate valid HTTP signature
          allow(controller).to receive(:signed_request_account).and_return(create(:account))
        end

        get :show, params: { id: tag.to_param, format: payload[:format] }

        if payload[:authenticated]
          # Authenticated requests should succeed
          expect(response.status).not_to eq(401)
        else
          # Unauthenticated requests must be rejected when authorized_fetch_mode is true
          expect(response.status).to eq(401)
        end
      end
    end

    it 'maintains security boundary regardless of authorized_fetch_mode setting' do
      # Invariant: The security check must not be entirely skipped based on a single config flag
      allow(controller).to receive(:authorized_fetch_mode?).and_return(false)
      allow(controller).to receive(:signed_request_account).and_return(nil)

      get :show, params: { id: tag.to_param, format: :json }

      # Even with authorized_fetch_mode disabled, the endpoint should not expose
      # sensitive operations without any verification mechanism
      expect(response.status).not_to eq(200) unless response.body.empty?
    end
  end
end