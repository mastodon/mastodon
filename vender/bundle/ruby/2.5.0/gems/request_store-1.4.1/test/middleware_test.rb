require 'minitest/test'
require 'minitest/autorun'

require 'request_store'

class MiddlewareTest < Minitest::Test
  def setup
    @app = RackApp.new
    @middleware = RequestStore::Middleware.new(@app)
  end

  def call_middleware(opts = {})
    _, _, proxy = @middleware.call(opts)
    proxy.close
  end

  def test_middleware_resets_store
    2.times do
      call_middleware
    end

    assert_equal 1, @app.last_value
    assert_equal({}, RequestStore.store)
  end

  def test_middleware_resets_store_on_error
    e = assert_raises RuntimeError do
      call_middleware({:error => true})
    end

    assert_equal 'FAIL', e.message
    assert_equal({}, RequestStore.store)
  end

  def test_middleware_begins_store
    call_middleware
    assert_equal true, @app.store_active
  end

  def test_middleware_ends_store
    call_middleware

    assert_equal false, RequestStore.active?
  end

  def test_middleware_ends_store_on_error
    assert_raises RuntimeError do
      call_middleware({:error => true})
    end

    assert_equal false, RequestStore.active?
  end

  def test_middleware_stores_until_proxy_closes
    _, _, proxy = @middleware.call({})

    assert_equal 1, @app.last_value
    assert RequestStore.active?

    proxy.close

    refute RequestStore.active?
    refute RequestStore.store[:foo]
  end
end
