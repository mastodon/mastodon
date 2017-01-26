web_app = Doorkeeper::Application.new(name: 'Web', superapp: true, redirect_uri: Doorkeeper.configuration.native_redirect_uri, scopes: 'read write follow')
web_app.save!
if Rails.env.development?
	domain = ENV['LOCAL_DOMAIN'] || Rails.configuration.x.local_domain
	account = Account.where(username: 'admin').first_or_initialize(username: 'admin').save!
	user = User.where(email: "admin@#{domain}").first_or_initialize(:email => "admin@#{domain}", :password => 'mastodonadmin', :password_confirmation => 'mastodonadmin', :confirmed_at => Time.now, :admin => true, :account => Account.where(username: 'admin').first).save!
end
