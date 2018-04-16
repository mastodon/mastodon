require File.join(File.dirname(__FILE__), 'basic')

class BasicAuth < Basic
  before do
    auth ||= Rack::Auth::Basic::Request.new(request.env)
    user, pass = auth.provided? && auth.basic? && auth.credentials
    unless [user, pass] == ["test_user", "test_password"]
      response['WWW-Authenticate'] = %(Basic realm="Restricted Area")
      throw(:halt, [401, "Not authorized\n"])
    end
  end
end

run BasicAuth
