class SetupLocalAccountService < BaseService
  # Setup an account for a new user instance by generating
  # an RSA key pair and a profile
  # @param [User] user Unsaved user instance
  # @param [String] username
  def call(user, username)
    user.build_account

    user.account.username = username
    user.account.domain   = nil

    keypair = OpenSSL::PKey::RSA.new(2048)
    user.account.private_key = keypair.to_pem
    user.account.public_key  = keypair.public_key.to_pem

    user.save!
  end
end
