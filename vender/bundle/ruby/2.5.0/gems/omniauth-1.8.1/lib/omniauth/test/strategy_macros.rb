module OmniAuth
  module Test
    module StrategyMacros
      def sets_an_auth_hash
        it 'sets an auth hash' do
          expect(last_request.env['omniauth.auth']).to be_kind_of(Hash)
        end
      end

      def sets_provider_to(provider)
        it "sets the provider to #{provider}" do
          expect((last_request.env['omniauth.auth'] || {})['provider']).to eq provider
        end
      end

      def sets_uid_to(uid)
        it "sets the UID to #{uid}" do
          expect((last_request.env['omniauth.auth'] || {})['uid']).to eq uid
        end
      end

      def sets_user_info_to(user_info)
        it "sets the user_info to #{user_info}" do
          expect((last_request.env['omniauth.auth'] || {})['user_info']).to eq user_info
        end
      end
    end
  end
end
