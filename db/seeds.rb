Doorkeeper::Application.create!(name: 'Web', superapp: true, redirect_uri: Doorkeeper.configuration.native_redirect_uri, scopes: 'read write follow push')

domain = ENV['LOCAL_DOMAIN'] || Rails.configuration.x.local_domain
account = Account.find_or_initialize_by(id: -99, actor_type: 'Application', locked: true, username: domain)
account.save!

if Rails.env.development?
  admin  = Account.where(username: 'admin').first_or_initialize(username: 'admin')
  admin.save(validate: false)
  User.where(email: "admin@localhost").first_or_initialize(email: "admin@localhost", password: 'mastodonadmin', password_confirmation: 'mastodonadmin', confirmed_at: Time.now.utc, admin: true, account: admin, agreement: true, approved: true).save!
end
