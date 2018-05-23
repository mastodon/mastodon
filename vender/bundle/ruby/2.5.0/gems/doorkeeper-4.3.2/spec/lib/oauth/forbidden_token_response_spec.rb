require 'spec_helper'
require 'active_model'
require 'doorkeeper'
require 'doorkeeper/oauth/forbidden_token_response'

module Doorkeeper::OAuth
  describe ForbiddenTokenResponse do
    describe '#name' do
      it  { expect(subject.name).to eq(:invalid_scope) }
    end

    describe '#status' do
      it { expect(subject.status).to eq(:forbidden) }
    end

    describe :from_scopes do
      it 'should have a list of acceptable scopes' do
        response = ForbiddenTokenResponse.from_scopes(["public"])
        expect(response.description).to include('public')
      end
    end
  end
end
