require 'minitest/autorun'
begin
  require 'rack/session/memcache'
  require 'rack/lint'
  require 'rack/mock'
  require 'thread'

  describe Rack::Session::Memcache do
    session_key = Rack::Session::Memcache::DEFAULT_OPTIONS[:key]
    session_match = /#{session_key}=([0-9a-fA-F]+);/
    incrementor = lambda do |env|
      env["rack.session"]["counter"] ||= 0
      env["rack.session"]["counter"] += 1
      Rack::Response.new(env["rack.session"].inspect).to_a
    end
    drop_session = Rack::Lint.new(proc do |env|
      env['rack.session.options'][:drop] = true
      incrementor.call(env)
    end)
    renew_session = Rack::Lint.new(proc do |env|
      env['rack.session.options'][:renew] = true
      incrementor.call(env)
    end)
    defer_session = Rack::Lint.new(proc do |env|
      env['rack.session.options'][:defer] = true
      incrementor.call(env)
    end)
    skip_session = Rack::Lint.new(proc do |env|
      env['rack.session.options'][:skip] = true
      incrementor.call(env)
    end)
    incrementor = Rack::Lint.new(incrementor)

    # test memcache connection
    Rack::Session::Memcache.new(incrementor)

    it "faults on no connection" do
      lambda {
        Rack::Session::Memcache.new(incrementor, :memcache_server => 'nosuchserver')
      }.must_raise(RuntimeError).message.must_equal 'No memcache servers'
    end

    it "connects to existing server" do
      test_pool = MemCache.new(incrementor, :namespace => 'test:rack:session')
      test_pool.namespace.must_equal 'test:rack:session'
    end

    it "passes options to MemCache" do
      pool = Rack::Session::Memcache.new(incrementor, :namespace => 'test:rack:session')
      pool.pool.namespace.must_equal 'test:rack:session'
    end

    it "creates a new cookie" do
      pool = Rack::Session::Memcache.new(incrementor)
      res = Rack::MockRequest.new(pool).get("/")
      res["Set-Cookie"].must_include "#{session_key}="
      res.body.must_equal '{"counter"=>1}'
    end

    it "determines session from a cookie" do
      pool = Rack::Session::Memcache.new(incrementor)
      req = Rack::MockRequest.new(pool)
      res = req.get("/")
      cookie = res["Set-Cookie"]
      req.get("/", "HTTP_COOKIE" => cookie).
        body.must_equal '{"counter"=>2}'
      req.get("/", "HTTP_COOKIE" => cookie).
        body.must_equal '{"counter"=>3}'
    end

    it "determines session only from a cookie by default" do
      pool = Rack::Session::Memcache.new(incrementor)
      req = Rack::MockRequest.new(pool)
      res = req.get("/")
      sid = res["Set-Cookie"][session_match, 1]
      req.get("/?rack.session=#{sid}").
        body.must_equal '{"counter"=>1}'
      req.get("/?rack.session=#{sid}").
        body.must_equal '{"counter"=>1}'
    end

    it "determines session from params" do
      pool = Rack::Session::Memcache.new(incrementor, :cookie_only => false)
      req = Rack::MockRequest.new(pool)
      res = req.get("/")
      sid = res["Set-Cookie"][session_match, 1]
      req.get("/?rack.session=#{sid}").
        body.must_equal '{"counter"=>2}'
      req.get("/?rack.session=#{sid}").
        body.must_equal '{"counter"=>3}'
    end

    it "survives nonexistant cookies" do
      bad_cookie = "rack.session=blarghfasel"
      pool = Rack::Session::Memcache.new(incrementor)
      res = Rack::MockRequest.new(pool).
        get("/", "HTTP_COOKIE" => bad_cookie)
      res.body.must_equal '{"counter"=>1}'
      cookie = res["Set-Cookie"][session_match]
      cookie.wont_match(/#{bad_cookie}/)
    end

    it "maintains freshness" do
      pool = Rack::Session::Memcache.new(incrementor, :expire_after => 3)
      res = Rack::MockRequest.new(pool).get('/')
      res.body.must_include '"counter"=>1'
      cookie = res["Set-Cookie"]
      res = Rack::MockRequest.new(pool).get('/', "HTTP_COOKIE" => cookie)
      res["Set-Cookie"].must_equal cookie
      res.body.must_include '"counter"=>2'
      puts 'Sleeping to expire session' if $DEBUG
      sleep 4
      res = Rack::MockRequest.new(pool).get('/', "HTTP_COOKIE" => cookie)
      res["Set-Cookie"].wont_equal cookie
      res.body.must_include '"counter"=>1'
    end

    it "does not send the same session id if it did not change" do
      pool = Rack::Session::Memcache.new(incrementor)
      req = Rack::MockRequest.new(pool)

      res0 = req.get("/")
      cookie = res0["Set-Cookie"][session_match]
      res0.body.must_equal '{"counter"=>1}'

      res1 = req.get("/", "HTTP_COOKIE" => cookie)
      res1["Set-Cookie"].must_be_nil
      res1.body.must_equal '{"counter"=>2}'

      res2 = req.get("/", "HTTP_COOKIE" => cookie)
      res2["Set-Cookie"].must_be_nil
      res2.body.must_equal '{"counter"=>3}'
    end

    it "deletes cookies with :drop option" do
      pool = Rack::Session::Memcache.new(incrementor)
      req = Rack::MockRequest.new(pool)
      drop = Rack::Utils::Context.new(pool, drop_session)
      dreq = Rack::MockRequest.new(drop)

      res1 = req.get("/")
      session = (cookie = res1["Set-Cookie"])[session_match]
      res1.body.must_equal '{"counter"=>1}'

      res2 = dreq.get("/", "HTTP_COOKIE" => cookie)
      res2["Set-Cookie"].must_be_nil
      res2.body.must_equal '{"counter"=>2}'

      res3 = req.get("/", "HTTP_COOKIE" => cookie)
      res3["Set-Cookie"][session_match].wont_equal session
      res3.body.must_equal '{"counter"=>1}'
    end

    it "provides new session id with :renew option" do
      pool = Rack::Session::Memcache.new(incrementor)
      req = Rack::MockRequest.new(pool)
      renew = Rack::Utils::Context.new(pool, renew_session)
      rreq = Rack::MockRequest.new(renew)

      res1 = req.get("/")
      session = (cookie = res1["Set-Cookie"])[session_match]
      res1.body.must_equal '{"counter"=>1}'

      res2 = rreq.get("/", "HTTP_COOKIE" => cookie)
      new_cookie = res2["Set-Cookie"]
      new_session = new_cookie[session_match]
      new_session.wont_equal session
      res2.body.must_equal '{"counter"=>2}'

      res3 = req.get("/", "HTTP_COOKIE" => new_cookie)
      res3.body.must_equal '{"counter"=>3}'

      # Old cookie was deleted
      res4 = req.get("/", "HTTP_COOKIE" => cookie)
      res4.body.must_equal '{"counter"=>1}'
    end

    it "omits cookie with :defer option but still updates the state" do
      pool = Rack::Session::Memcache.new(incrementor)
      count = Rack::Utils::Context.new(pool, incrementor)
      defer = Rack::Utils::Context.new(pool, defer_session)
      dreq = Rack::MockRequest.new(defer)
      creq = Rack::MockRequest.new(count)

      res0 = dreq.get("/")
      res0["Set-Cookie"].must_be_nil
      res0.body.must_equal '{"counter"=>1}'

      res0 = creq.get("/")
      res1 = dreq.get("/", "HTTP_COOKIE" => res0["Set-Cookie"])
      res1.body.must_equal '{"counter"=>2}'
      res2 = dreq.get("/", "HTTP_COOKIE" => res0["Set-Cookie"])
      res2.body.must_equal '{"counter"=>3}'
    end

    it "omits cookie and state update with :skip option" do
      pool = Rack::Session::Memcache.new(incrementor)
      count = Rack::Utils::Context.new(pool, incrementor)
      skip = Rack::Utils::Context.new(pool, skip_session)
      sreq = Rack::MockRequest.new(skip)
      creq = Rack::MockRequest.new(count)

      res0 = sreq.get("/")
      res0["Set-Cookie"].must_be_nil
      res0.body.must_equal '{"counter"=>1}'

      res0 = creq.get("/")
      res1 = sreq.get("/", "HTTP_COOKIE" => res0["Set-Cookie"])
      res1.body.must_equal '{"counter"=>2}'
      res2 = sreq.get("/", "HTTP_COOKIE" => res0["Set-Cookie"])
      res2.body.must_equal '{"counter"=>2}'
    end

    it "updates deep hashes correctly" do
      hash_check = proc do |env|
        session = env['rack.session']
        unless session.include? 'test'
          session.update :a => :b, :c => { :d => :e },
            :f => { :g => { :h => :i} }, 'test' => true
        else
          session[:f][:g][:h] = :j
        end
        [200, {}, [session.inspect]]
      end
      pool = Rack::Session::Memcache.new(hash_check)
      req = Rack::MockRequest.new(pool)

      res0 = req.get("/")
      session_id = (cookie = res0["Set-Cookie"])[session_match, 1]
      ses0 = pool.pool.get(session_id, true)

      req.get("/", "HTTP_COOKIE" => cookie)
      ses1 = pool.pool.get(session_id, true)

      ses1.wont_equal ses0
    end

    # anyone know how to do this better?
    it "cleanly merges sessions when multithreaded" do
      skip unless $DEBUG

      warn 'Running multithread test for Session::Memcache'
      pool = Rack::Session::Memcache.new(incrementor)
      req = Rack::MockRequest.new(pool)

      res = req.get('/')
      res.body.must_equal '{"counter"=>1}'
      cookie = res["Set-Cookie"]
      session_id = cookie[session_match, 1]

      delta_incrementor = lambda do |env|
        # emulate disconjoinment of threading
        env['rack.session'] = env['rack.session'].dup
        Thread.stop
        env['rack.session'][(Time.now.usec*rand).to_i] = true
        incrementor.call(env)
      end
      tses = Rack::Utils::Context.new pool, delta_incrementor
      treq = Rack::MockRequest.new(tses)
      tnum = rand(7).to_i+5
      r = Array.new(tnum) do
        Thread.new(treq) do |run|
          run.get('/', "HTTP_COOKIE" => cookie, 'rack.multithread' => true)
        end
      end.reverse.map{|t| t.run.join.value }
      r.each do |request|
        request['Set-Cookie'].must_equal cookie
        request.body.must_include '"counter"=>2'
      end

      session = pool.pool.get(session_id)
      session.size.must_equal tnum+1 # counter
      session['counter'].must_equal 2 # meeeh

      tnum = rand(7).to_i+5
      r = Array.new(tnum) do
        app = Rack::Utils::Context.new pool, time_delta
        req = Rack::MockRequest.new app
        Thread.new(req) do |run|
          run.get('/', "HTTP_COOKIE" => cookie, 'rack.multithread' => true)
        end
      end.reverse.map{|t| t.run.join.value }
      r.each do |request|
        request['Set-Cookie'].must_equal cookie
        request.body.must_include '"counter"=>3'
      end

      session = pool.pool.get(session_id)
      session.size.must_equal tnum+1
      session['counter'].must_equal 3

      drop_counter = proc do |env|
        env['rack.session'].delete 'counter'
        env['rack.session']['foo'] = 'bar'
        [200, {'Content-Type'=>'text/plain'}, env['rack.session'].inspect]
      end
      tses = Rack::Utils::Context.new pool, drop_counter
      treq = Rack::MockRequest.new(tses)
      tnum = rand(7).to_i+5
      r = Array.new(tnum) do
        Thread.new(treq) do |run|
          run.get('/', "HTTP_COOKIE" => cookie, 'rack.multithread' => true)
        end
      end.reverse.map{|t| t.run.join.value }
      r.each do |request|
        request['Set-Cookie'].must_equal cookie
        request.body.must_include '"foo"=>"bar"'
      end

      session = pool.pool.get(session_id)
      session.size.must_equal r.size+1
      session['counter'].must_be_nil?
      session['foo'].must_equal 'bar'
    end
  end
rescue RuntimeError
  $stderr.puts "Skipping Rack::Session::Memcache tests. Start memcached and try again."
rescue LoadError
  $stderr.puts "Skipping Rack::Session::Memcache tests (Memcache is required). `gem install memcache-client` and try again."
end
