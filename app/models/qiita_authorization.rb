class QiitaAuthorization < ApplicationRecord
  belongs_to :user, inverse_of: :qiita_authorization
end
