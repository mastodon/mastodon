class OauthAuthorization < ApplicationRecord
  belongs_to :user, inverse_of: :oauth_authorizations
end
