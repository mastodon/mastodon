web_app = Doorkeeper::Application.new(name: 'Web', superapp: true, redirect_uri: Doorkeeper.configuration.native_redirect_uri, scopes: 'read write follow')
web_app.save!
