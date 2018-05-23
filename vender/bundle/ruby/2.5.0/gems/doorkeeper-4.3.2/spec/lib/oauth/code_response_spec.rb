require 'spec_helper'

module Doorkeeper
  module OAuth
    describe CodeResponse do
      describe '.redirect_uri' do
        context 'when generating the redirect URI for an implicit grant' do
          let :pre_auth do
            double(
              :pre_auth,
              client: double(:application, id: 1),
              redirect_uri: 'http://tst.com/cb',
              state: nil,
              scopes: Scopes.from_string('public'),
            )
          end

          let :auth do
            Authorization::Token.new(pre_auth, double(id: 1)).tap do |c|
              c.issue_token
              allow(c.token).to receive(:expires_in_seconds).and_return(3600)
            end
          end

          subject { CodeResponse.new(pre_auth, auth, response_on_fragment: true).redirect_uri }

          it 'includes the remaining TTL of the token relative to the time the token was generated' do
            expect(subject).to include('expires_in=3600')
          end
        end
      end
    end
  end
end
