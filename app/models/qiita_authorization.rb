# == Schema Information
#
# Table name: qiita_authorizations
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  uid        :string
#  token      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class QiitaAuthorization < ApplicationRecord
  belongs_to :user, inverse_of: :qiita_authorization
end
