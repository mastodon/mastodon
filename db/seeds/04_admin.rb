# frozen_string_literal: true

if Rails.env.development?
  domain = ENV['LOCAL_DOMAIN'] || Rails.configuration.x.local_domain
  domain = domain.gsub(/:\d+$/, '')

  admin = Account.where(username: 'admin').first_or_initialize(username: 'admin')
  admin.save(validate: false)

  user = User.where(email: "admin@#{domain}").first_or_initialize(email: "admin@#{domain}", password: 'mastodonadmin', password_confirmation: 'mastodonadmin', confirmed_at: Time.now.utc, role: UserRole.find_by(name: 'Owner'), account: admin, agreement: true, approved: true)
  user.save!
  user.approve!
end
