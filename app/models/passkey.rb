# == Schema Information
#
# Table name: passkeys
#
#  id           :bigint(8)        not null, primary key
#  user_id      :bigint(8)        not null
#  label        :string
#  external_id  :string
#  public_key   :string
#  sign_count   :integer
#  last_used_at :datetime
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
class Passkey < ApplicationRecord
    belongs_to :pkuser
  
    validates :label, uniqueness: { scope: :pkuser}
    validates :external_id, uniqueness: true
    validates :public_key, uniqueness: true
  end
