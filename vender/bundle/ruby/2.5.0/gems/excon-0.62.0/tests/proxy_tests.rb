Shindo.tests('Excon proxy support') do
  env_init

  tests('proxy configuration') do

    tests('no proxy') do
      tests('connection.data[:proxy]').returns(nil) do
        connection = Excon.new('http://foo.com')
        connection.data[:proxy]
      end
    end

    tests('empty proxy') do
      tests('connection.data[:proxy]').returns(nil) do
        connection = Excon.new('http://foo.com', :proxy => '')
        connection.data[:proxy]
      end
    end

    tests('with fully-specified proxy: https://myproxy.net:8080') do
      connection = nil

      tests('connection.data[:proxy][:host]').returns('myproxy.net') do
        connection = Excon.new('http://foo.com', :proxy => 'https://myproxy.net:8080')
        connection.data[:proxy][:host]
      end

      tests('connection.data[:proxy][:port]').returns(8080) do
        connection.data[:proxy][:port]
      end

      tests('connection.data[:proxy][:scheme]').returns('https') do
        connection.data[:proxy][:scheme]
      end
    end

    tests('with fully-specified Unix socket proxy: unix:///') do
      connection = nil

      tests('connection.data[:proxy][:host]').returns(nil) do
        connection = Excon.new('http://foo.com', :proxy => 'unix:///tmp/myproxy.sock')
        connection.data[:proxy][:host]
      end

      tests('connection.data[:proxy][:port]').returns(nil) do
        connection.data[:proxy][:port]
      end

      tests('connection.data[:proxy][:scheme]').returns('unix') do
        connection.data[:proxy][:scheme]
      end

      tests('connection.data[:proxy][:path]').returns('/tmp/myproxy.sock') do
        connection.data[:proxy][:path]
      end
    end

    def env_proxy_tests(env)
      env_init(env)

      tests('an http connection') do
        connection = nil

        tests('connection.data[:proxy][:host]').returns('myproxy') do
          connection = Excon.new('http://foo.com')
          connection.data[:proxy][:host]
        end

        tests('connection.data[:proxy][:port]').returns(8080) do
          connection.data[:proxy][:port]
        end

        tests('connection.data[:proxy][:scheme]').returns('http') do
          connection.data[:proxy][:scheme]
        end

        tests('with disable_proxy set') do
          connection = nil

          tests('connection.data[:proxy]').returns(nil) do
            connection = Excon.new('http://foo.com', :disable_proxy => true)
            connection.data[:proxy]
          end
        end
      end

      tests('an https connection') do
        connection = nil

        tests('connection.data[:proxy][:host]').returns('mysecureproxy') do
          connection = Excon.new('https://secret.com')
          connection.data[:proxy][:host]
        end

        tests('connection.data[:proxy][:port]').returns(8081) do
          connection.data[:proxy][:port]
        end

        tests('connection.data[:proxy][:scheme]').returns('http') do
          connection.data[:proxy][:scheme]
        end

        tests('with disable_proxy set') do
          connection = nil

          tests('connection.data[:proxy]').returns(nil) do
            connection = Excon.new('https://foo.com', :disable_proxy => true)
            connection.data[:proxy]
          end
        end
      end

      tests('http proxy from the environment overrides config') do
        connection = nil

        tests('connection.data[:proxy][:host]').returns('myproxy') do
          connection = Excon.new('http://foo.com', :proxy => 'http://hard.coded.proxy:6666')
          connection.data[:proxy][:host]
        end

        tests('connection.data[:proxy][:port]').returns(8080) do
          connection.data[:proxy][:port]
        end
      end

      tests('an http connection in no_proxy') do
        tests('connection.data[:proxy]').returns(nil) do
          connection = Excon.new('http://somesubdomain.noproxy')
          connection.data[:proxy]
        end
      end

      tests('an http connection not completely matching no_proxy') do
        tests('connection.data[:proxy][:host]').returns('myproxy') do
          connection = Excon.new('http://noproxy2')
          connection.data[:proxy][:host]
        end
      end

      tests('an http connection with subdomain in no_proxy') do
        tests('connection.data[:proxy]').returns(nil) do
          connection = Excon.new('http://a.subdomain.noproxy2')
          connection.data[:proxy]
        end
      end

      env_restore
    end

    tests('with complete proxy config from the environment') do
      env = {
        'http_proxy' => 'http://myproxy:8080',
        'https_proxy' => 'http://mysecureproxy:8081',
        'no_proxy' => 'noproxy, subdomain.noproxy2'
      }
      tests('lowercase') { env_proxy_tests(env) }
      upperenv = {}
      env.each do |k, v|
        upperenv[k.upcase] = v
      end
      tests('uppercase') { env_proxy_tests(upperenv) }
    end

    tests('with only http_proxy config from the environment') do
      env_init({'http_proxy' => 'http://myproxy:8080' })

      tests('an https connection') do
        connection = nil

        tests('connection.data[:proxy][:host]').returns('myproxy') do
          connection = Excon.new('https://secret.com')
          connection.data[:proxy][:host]
        end

        tests('connection.data[:proxy][:port]').returns(8080) do
          connection.data[:proxy][:port]
        end

        tests('connection.data[:proxy][:scheme]').returns('http') do
          connection.data[:proxy][:scheme]
        end
      end

      env_restore
    end

    tests('with a unix socket proxy config from the environment') do
      env_init({
        'http_proxy' => 'unix:///tmp/myproxy.sock',
      })

      tests('an https connection') do
        connection = nil

        tests('connection.data[:proxy][:host]').returns(nil) do
          connection = Excon.new('https://secret.com')
          connection.data[:proxy][:host]
        end

        tests('connection.data[:proxy][:port]').returns(nil) do
          connection.data[:proxy][:port]
        end

        tests('connection.data[:proxy][:scheme]').returns('unix') do
          connection.data[:proxy][:scheme]
        end

        tests('connection.data[:proxy][:path]').returns('/tmp/myproxy.sock') do
          connection.data[:proxy][:path]
        end
      end

      env_restore
    end

  end

  with_rackup('proxy.ru') do

    tests('http proxying: http://foo.com:8080') do
      response = nil

      tests('response.status').returns(200) do
        connection = Excon.new('http://foo.com:8080', :proxy => 'http://127.0.0.1:9292')
        response = connection.request(:method => :get, :path => '/bar', :query => {:alpha => 'kappa'})

        response.status
      end

      # must be absolute form for proxy requests
      tests('sent Request URI').returns('http://foo.com:8080/bar?alpha=kappa') do
        response.headers['Sent-Request-Uri']
      end

      tests('sent Sent-Host header').returns('foo.com:8080') do
        response.headers['Sent-Host']
      end

      tests('sent Proxy-Connection header').returns('Keep-Alive') do
        response.headers['Sent-Proxy-Connection']
      end

      tests('response.body (proxied content)').returns('proxied content') do
        response.body
      end
    end

    tests('http proxying: http://user:pass@foo.com:8080') do
      response = nil

      tests('response.status').returns(200) do
        connection = Excon.new('http://foo.com:8080', :proxy => 'http://user:pass@127.0.0.1:9292')
        response = connection.request(:method => :get, :path => '/bar', :query => {:alpha => 'kappa'})

        response.status
      end

      # must be absolute form for proxy requests
      tests('sent Request URI').returns('http://foo.com:8080/bar?alpha=kappa') do
        response.headers['Sent-Request-Uri']
      end

      tests('sent Host header').returns('foo.com:8080') do
        response.headers['Sent-Host']
      end

      tests('sent Proxy-Connection header').returns('Keep-Alive') do
        response.headers['Sent-Proxy-Connection']
      end

      tests('response.body (proxied content)').returns('proxied content') do
        response.body
      end
    end

  end

  with_unicorn('proxy.ru', 'unix:///tmp/myproxy.sock') do
    pending if RUBY_PLATFORM == 'java' # need to find suitable server for jruby

    tests('http proxying over unix socket: http://foo.com:8080') do
      response = nil

      tests('response.status').returns(200) do
        connection = Excon.new('http://foo.com:8080', :proxy => 'unix:///tmp/myproxy.sock')
        response = connection.request(:method => :get, :path => '/bar', :query => {:alpha => 'kappa'})

        response.status
      end

      tests('sent Sent-Host header').returns('foo.com:8080') do
        response.headers['Sent-Host']
      end

      tests('sent Proxy-Connection header').returns('Keep-Alive') do
        response.headers['Sent-Proxy-Connection']
      end

      tests('response.body (proxied content)').returns('proxied content') do
        response.body
      end
    end
  end

  env_restore
end
