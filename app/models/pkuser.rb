class Pkuser < ApplicationRecord
    # Include default devise modules. Others available are:
    # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
    devise :passkey_authenticatable, :registerable, :rememberable
  
    has_many :passkeys, dependent: :destroy
  
    def self.passkeys_class
      Passkey
    end
  
    def self.find_for_passkey(passkey)
      self.find_by(id: passkey.pkuser.id)
    end
  end
  
  
  Devise.add_module :passkey_authenticatable,
                    model: 'devise/passkeys/model',
                    route: {session: [nil, :new, :create, :destroy] },
                    controller: 'controller/sessions',
                    strategy: true
  