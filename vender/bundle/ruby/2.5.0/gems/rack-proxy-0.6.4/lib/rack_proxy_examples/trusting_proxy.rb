class TrustingProxy < Rack::Proxy

  def rewrite_env(env)
    env["HTTP_HOST"] = "self-signed.badssl.com"

    # We are going to trust the self-signed SSL 
    env["rack.ssl_verify_none"] = true
    env
  end

  def rewrite_response(triplet)
    status, headers, body = triplet
    
    # if you rewrite env, it appears that content-length isn't calculated correctly
    # resulting in only partial responses being sent to users
    # you can remove it or recalculate it here
    headers["content-length"] = nil

    triplet
  end

end

Rails.application.config.middleware.use TrustingProxy, backend: 'https://self-signed.badssl.com', streaming: false
