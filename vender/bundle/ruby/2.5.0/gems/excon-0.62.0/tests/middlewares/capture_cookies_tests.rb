Shindo.tests("Excon redirecting with cookie preserved") do
  env_init

  with_rackup('redirecting_with_cookie.ru') do
    tests('second request will send cookies set by the first').returns('ok') do
      Excon.get(
        'http://127.0.0.1:9292',
        :path         => '/sets_cookie',
        :middlewares  => Excon.defaults[:middlewares] + [Excon::Middleware::CaptureCookies, Excon::Middleware::RedirectFollower]
      ).body
    end

    tests('second request will send multiple cookies set by the first').returns('ok') do
      Excon.get(
        'http://127.0.0.1:9292',
        :path         => '/sets_multi_cookie',
        :middlewares  => Excon.defaults[:middlewares] + [Excon::Middleware::CaptureCookies, Excon::Middleware::RedirectFollower]
      ).body
    end
  end

  with_rackup('redirecting.ru') do
    tests("runs normally when there are no cookies set").returns('ok') do
      Excon.post(
        'http://127.0.0.1:9292',
        :path         => '/first',
        :middlewares  => Excon.defaults[:middlewares] + [Excon::Middleware::CaptureCookies, Excon::Middleware::RedirectFollower],
        :body => "a=Some_content"
      ).body
    end
  end

  env_restore
end
