class TestController < ActionController::Base
  def no_session_access
    head :ok
  end

  def set_session_value
    session[:foo] = "bar"
    head :ok
  end

  def set_session_value_with_expiry
    request.session_options[:expire_after] = 1.second
    set_session_value
  end

  def set_serialized_session_value
    session[:foo] = SessionAutoloadTest::Foo.new
    head :ok
  end

  def get_session_value
    render plain: "foo: #{session[:foo].inspect}"
  end

  def get_session_id
    session_id = request.session_options[:id] || cookies["_session_id"]
    render plain: session_id
  end

  def call_reset_session
    session[:bar]
    reset_session
    session[:bar] = "baz"
    head :ok
  end

  def rescue_action(e) raise end
end
