class ForwardHost < Rack::Proxy

  def rewrite_env(env)
    env["HTTP_HOST"] = "example.com"
    env
  end

  def rewrite_response(triplet)
    status, headers, body = triplet

    # example of inserting an additional header
    headers["X-Foo"] = "Bar"
    
    # if you rewrite env, it appears that content-length isn't calculated correctly
    # resulting in only partial responses being sent to users
    # you can remove it or recalculate it here
    headers["content-length"] = nil

    triplet
  end

end

Rails.application.config.middleware.use ForwardHost, backend: 'http://example.com', streaming: false
