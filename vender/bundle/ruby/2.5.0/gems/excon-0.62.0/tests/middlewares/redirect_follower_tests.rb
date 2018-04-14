Shindo.tests('Excon redirector support') do
  env_init

  tests("request(:method => :get, :path => '/old').body").returns('new') do
    Excon.stub(
      { :path => '/old' },
      {
        :headers  => { 'Location' => 'http://127.0.0.1:9292/new' },
        :body     => 'old',
        :status   => 301
      }
    )

    Excon.stub(
      { :path => '/new' },
      {
        :body     => 'new',
        :status   => 200
      }
    )

    Excon.get(
      'http://127.0.0.1:9292',
      :path         => '/old',
      :middlewares  => Excon.defaults[:middlewares] + [Excon::Middleware::RedirectFollower],
      :mock         => true
    ).body
  end

  env_restore
end

Shindo.tests('Excon redirect support for relative Location headers') do
  env_init

  tests("request(:method => :get, :path => '/old').body").returns('new') do
    Excon.stub(
      { :path => '/old' },
      {
        :headers  => { 'Location' => '/new' },
        :body     => 'old',
        :status   => 301
      }
    )

    Excon.stub(
      { :path => '/new' },
      {
        :body     => 'new',
        :status   => 200
      }
    )

    Excon.get(
      'http://127.0.0.1:9292',
      :path         => '/old',
      :middlewares  => Excon.defaults[:middlewares] + [Excon::Middleware::RedirectFollower],
      :mock         => true
    ).body
  end

  env_restore
end

Shindo.tests('Excon redirect support for relative Location headers with dot segments') do
  env_init

  tests("request(:method => :get, :path => '/foo/baz/').body").returns('/foo/bar/') do
    Excon.stub(
      { :path => '/foo/baz/' },
      {
        :headers  => { 'Location' => '../bar/' },
        :body     => '/foo/baz/',
        :status   => 301
      }
    )

    Excon.stub(
      { :path => '/foo/bar/' },
      {
        :body     => '/foo/bar/',
        :status   => 200
      }
    )

    Excon.get(
      'http://127.0.0.1:9292',
      :path         => '/foo/baz/',
      :middlewares  => Excon.defaults[:middlewares] + [Excon::Middleware::RedirectFollower],
      :mock         => true
    ).body
  end

  env_restore
end

Shindo.tests("Excon redirecting post request") do
  env_init

  with_rackup('redirecting.ru') do
    tests("request not have content-length and body").returns('ok') do
      Excon.post(
        'http://127.0.0.1:9292',
        :path         => '/first',
        :middlewares  => Excon.defaults[:middlewares] + [Excon::Middleware::RedirectFollower],
        :body => "a=Some_content"
      ).body
    end
  end

  env_restore
end
