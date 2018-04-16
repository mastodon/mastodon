require File.expand_path('helper', File.dirname(__FILE__))
require 'tmpdir'

module TestHTTPCookieJar
  class TestAutoloading < Test::Unit::TestCase
    def test_nonexistent_store
      assert_raises(NameError) {
        HTTP::CookieJar::NonexistentStore
      }
    end

    def test_erroneous_store
      Dir.mktmpdir { |dir|
        Dir.mkdir(File.join(dir, 'http'))
        Dir.mkdir(File.join(dir, 'http', 'cookie_jar'))
        rb = File.join(dir, 'http', 'cookie_jar', 'erroneous_store.rb')
        File.open(rb, 'w').close
        $LOAD_PATH.unshift(dir)

        assert_raises(NameError) {
          HTTP::CookieJar::ErroneousStore
        }
        if RUBY_VERSION >= "1.9"
          assert_includes $LOADED_FEATURES, rb
        else
          assert_includes $LOADED_FEATURES, rb[(dir.size + 1)..-1]
        end
      }
    end

    def test_nonexistent_saver
      assert_raises(NameError) {
        HTTP::CookieJar::NonexistentSaver
      }
    end

    def test_erroneous_saver
      Dir.mktmpdir { |dir|
        Dir.mkdir(File.join(dir, 'http'))
        Dir.mkdir(File.join(dir, 'http', 'cookie_jar'))
        rb = File.join(dir, 'http', 'cookie_jar', 'erroneous_saver.rb')
        File.open(rb, 'w').close
        $LOAD_PATH.unshift(dir)

        assert_raises(NameError) {
          HTTP::CookieJar::ErroneousSaver
        }
        if RUBY_VERSION >= "1.9"
          assert_includes $LOADED_FEATURES, rb
        else
          assert_includes $LOADED_FEATURES, rb[(dir.size + 1)..-1]
        end
      }
    end
  end

  module CommonTests
    def setup(options = nil, options2 = nil)
      default_options = {
        :store => :hash,
        :gc_threshold => 1500, # increased by 10 for shorter test time
      }
      new_options  = default_options.merge(options || {})
      new_options2 = new_options.merge(options2 || {})
      @store_type = new_options[:store]
      @gc_threshold = new_options[:gc_threshold]
      @jar  = HTTP::CookieJar.new(new_options)
      @jar2 = HTTP::CookieJar.new(new_options2)
    end

    #def hash_store?
    #  @store_type == :hash
    #end

    def mozilla_store?
      @store_type == :mozilla
    end

    def cookie_values(options = {})
      {
        :name     => 'Foo',
        :value    => 'Bar',
        :path     => '/',
        :expires  => Time.at(Time.now.to_i + 10 * 86400), # to_i is important here
        :for_domain => true,
        :domain   => 'rubyforge.org',
        :origin   => 'http://rubyforge.org/'
      }.merge(options)
    end

    def test_empty?
      assert_equal true, @jar.empty?
      cookie = HTTP::Cookie.new(cookie_values)
      @jar.add(cookie)
      assert_equal false, @jar.empty?
      assert_equal false, @jar.empty?('http://rubyforge.org/')
      assert_equal true, @jar.empty?('http://example.local/')
    end

    def test_two_cookies_same_domain_and_name_different_paths
      url = URI 'http://rubyforge.org/'

      cookie = HTTP::Cookie.new(cookie_values)
      @jar.add(cookie)
      @jar.add(HTTP::Cookie.new(cookie_values(:path => '/onetwo')))

      assert_equal(1, @jar.cookies(url).length)
      assert_equal 2, @jar.cookies(URI('http://rubyforge.org/onetwo')).length
    end

    def test_domain_case
      url = URI 'http://rubyforge.org/'

      # Add one cookie with an expiration date in the future
      cookie = HTTP::Cookie.new(cookie_values)
      @jar.add(cookie)
      assert_equal(1, @jar.cookies(url).length)

      @jar.add(HTTP::Cookie.new(cookie_values(:domain => 'RuByForge.Org', :name => 'aaron')))

      assert_equal(2, @jar.cookies(url).length)

      url2 = URI 'http://RuByFoRgE.oRg/'
      assert_equal(2, @jar.cookies(url2).length)
    end

    def test_host_only
      url = URI.parse('http://rubyforge.org/')

      @jar.add(HTTP::Cookie.new(
          cookie_values(:domain => 'rubyforge.org', :for_domain => false)))

      assert_equal(1, @jar.cookies(url).length)

      assert_equal(1, @jar.cookies(URI('http://RubyForge.org/')).length)

      assert_equal(1, @jar.cookies(URI('https://RubyForge.org/')).length)

      assert_equal(0, @jar.cookies(URI('http://www.rubyforge.org/')).length)
    end

    def test_empty_value
      url = URI 'http://rubyforge.org/'
      values = cookie_values(:value => "")

      # Add one cookie with an expiration date in the future
      cookie = HTTP::Cookie.new(values)
      @jar.add(cookie)
      assert_equal(1, @jar.cookies(url).length)

      @jar.add HTTP::Cookie.new(values.merge(:domain => 'RuByForge.Org',
          :name   => 'aaron'))

      assert_equal(2, @jar.cookies(url).length)

      url2 = URI 'http://RuByFoRgE.oRg/'
      assert_equal(2, @jar.cookies(url2).length)
    end

    def test_add_future_cookies
      url = URI 'http://rubyforge.org/'

      # Add one cookie with an expiration date in the future
      cookie = HTTP::Cookie.new(cookie_values)
      @jar.add(cookie)
      assert_equal(1, @jar.cookies(url).length)

      # Add the same cookie, and we should still only have one
      @jar.add(HTTP::Cookie.new(cookie_values))
      assert_equal(1, @jar.cookies(url).length)

      # Make sure we can get the cookie from different paths
      assert_equal(1, @jar.cookies(URI('http://rubyforge.org/login')).length)

      # Make sure we can't get the cookie from different domains
      assert_equal(0, @jar.cookies(URI('http://google.com/')).length)
    end

    def test_add_multiple_cookies
      url = URI 'http://rubyforge.org/'

      # Add one cookie with an expiration date in the future
      cookie = HTTP::Cookie.new(cookie_values)
      @jar.add(cookie)
      assert_equal(1, @jar.cookies(url).length)

      # Add the same cookie, and we should still only have one
      @jar.add(HTTP::Cookie.new(cookie_values(:name => 'Baz')))
      assert_equal(2, @jar.cookies(url).length)

      # Make sure we can get the cookie from different paths
      assert_equal(2, @jar.cookies(URI('http://rubyforge.org/login')).length)

      # Make sure we can't get the cookie from different domains
      assert_equal(0, @jar.cookies(URI('http://google.com/')).length)
    end

    def test_add_multiple_cookies_with_the_same_name
      now = Time.now

      cookies = [
        { :value => 'a', :path => '/', },
        { :value => 'b', :path => '/abc/def/', :created_at => now - 1 },
        { :value => 'c', :path => '/abc/def/', :domain => 'www.rubyforge.org', :origin => 'http://www.rubyforge.org/abc/def/', :created_at => now },
        { :value => 'd', :path => '/abc/' },
      ].map { |attrs|
        HTTP::Cookie.new(cookie_values(attrs))
      }

      url = URI 'http://www.rubyforge.org/abc/def/ghi'

      cookies.permutation(cookies.size) { |shuffled|
        @jar.clear
        shuffled.each { |cookie| @jar.add(cookie) }
        assert_equal %w[b c d a], @jar.cookies(url).map { |cookie| cookie.value }
      }
    end

    def test_fall_back_rules_for_local_domains
      url = URI 'http://www.example.local'

      sld_cookie = HTTP::Cookie.new(cookie_values(:domain => '.example.local', :origin => url))
      @jar.add(sld_cookie)

      assert_equal(1, @jar.cookies(url).length)
    end

    def test_add_makes_exception_for_localhost
      url = URI 'http://localhost'

      tld_cookie = HTTP::Cookie.new(cookie_values(:domain => 'localhost', :origin => url))
      @jar.add(tld_cookie)

      assert_equal(1, @jar.cookies(url).length)
    end

    def test_add_cookie_for_the_parent_domain
      url = URI 'http://x.foo.com'

      cookie = HTTP::Cookie.new(cookie_values(:domain => '.foo.com', :origin => url))
      @jar.add(cookie)

      assert_equal(1, @jar.cookies(url).length)
    end

    def test_add_rejects_cookies_with_unknown_domain_or_path
      cookie = HTTP::Cookie.new(cookie_values.reject { |k,v| [:origin, :domain].include?(k) })
      assert_raises(ArgumentError) {
        @jar.add(cookie)
      }

      cookie = HTTP::Cookie.new(cookie_values.reject { |k,v| [:origin, :path].include?(k) })
      assert_raises(ArgumentError) {
        @jar.add(cookie)
      }
    end

    def test_add_does_not_reject_cookies_from_a_nested_subdomain
      url = URI 'http://y.x.foo.com'

      cookie = HTTP::Cookie.new(cookie_values(:domain => '.foo.com', :origin => url))
      @jar.add(cookie)

      assert_equal(1, @jar.cookies(url).length)
    end

    def test_cookie_without_leading_dot_does_not_cause_substring_match
      url = URI 'http://arubyforge.org/'

      cookie = HTTP::Cookie.new(cookie_values(:domain => 'rubyforge.org'))
      @jar.add(cookie)

      assert_equal(0, @jar.cookies(url).length)
    end

    def test_cookie_without_leading_dot_matches_subdomains
      url = URI 'http://admin.rubyforge.org/'

      cookie = HTTP::Cookie.new(cookie_values(:domain => 'rubyforge.org', :origin => url))
      @jar.add(cookie)

      assert_equal(1, @jar.cookies(url).length)
    end

    def test_cookies_with_leading_dot_match_subdomains
      url = URI 'http://admin.rubyforge.org/'

      @jar.add(HTTP::Cookie.new(cookie_values(:domain => '.rubyforge.org', :origin => url)))

      assert_equal(1, @jar.cookies(url).length)
    end

    def test_cookies_with_leading_dot_match_parent_domains
      url = URI 'http://rubyforge.org/'

      @jar.add(HTTP::Cookie.new(cookie_values(:domain => '.rubyforge.org', :origin => url)))

      assert_equal(1, @jar.cookies(url).length)
    end

    def test_cookies_with_leading_dot_match_parent_domains_exactly
      url = URI 'http://arubyforge.org/'

      @jar.add(HTTP::Cookie.new(cookie_values(:domain => '.rubyforge.org')))

      assert_equal(0, @jar.cookies(url).length)
    end

    def test_cookie_for_ipv4_address_matches_the_exact_ipaddress
      url = URI 'http://192.168.0.1/'

      cookie = HTTP::Cookie.new(cookie_values(:domain => '192.168.0.1', :origin => url))
      @jar.add(cookie)

      assert_equal(1, @jar.cookies(url).length)
    end

    def test_cookie_for_ipv6_address_matches_the_exact_ipaddress
      url = URI 'http://[fe80::0123:4567:89ab:cdef]/'

      cookie = HTTP::Cookie.new(cookie_values(:domain => '[fe80::0123:4567:89ab:cdef]', :origin => url))
      @jar.add(cookie)

      assert_equal(1, @jar.cookies(url).length)
    end

    def test_cookies_dot
      url = URI 'http://www.host.example/'

      @jar.add(HTTP::Cookie.new(cookie_values(:domain => 'www.host.example', :origin => url)))

      url = URI 'http://wwwxhost.example/'
      assert_equal(0, @jar.cookies(url).length)
    end

    def test_cookies_no_host
      url = URI 'file:///path/'

      @jar.add(HTTP::Cookie.new(cookie_values(:origin => url)))

      assert_equal(0, @jar.cookies(url).length)
    end

    def test_clear
      url = URI 'http://rubyforge.org/'

      # Add one cookie with an expiration date in the future
      cookie = HTTP::Cookie.new(cookie_values(:origin => url))
      @jar.add(cookie)
      @jar.add(HTTP::Cookie.new(cookie_values(:name => 'Baz', :origin => url)))
      assert_equal(2, @jar.cookies(url).length)

      @jar.clear

      assert_equal(0, @jar.cookies(url).length)
    end

    def test_save_cookies_yaml
      url = URI 'http://rubyforge.org/'

      # Add one cookie with an expiration date in the future
      cookie = HTTP::Cookie.new(cookie_values(:origin => url))
      s_cookie = HTTP::Cookie.new(cookie_values(:name => 'Bar',
          :expires => nil,
          :origin => url))

      @jar.add(cookie)
      @jar.add(s_cookie)
      @jar.add(HTTP::Cookie.new(cookie_values(:name => 'Baz', :for_domain => false, :origin => url)))

      assert_equal(3, @jar.cookies(url).length)

      Dir.mktmpdir do |dir|
        value = @jar.save(File.join(dir, "cookies.yml"))
        assert_same @jar, value

        @jar2.load(File.join(dir, "cookies.yml"))
        cookies = @jar2.cookies(url).sort_by { |cookie| cookie.name }
        assert_equal(2, cookies.length)
        assert_equal('Baz', cookies[0].name)
        assert_equal(false, cookies[0].for_domain)
        assert_equal('Foo', cookies[1].name)
        assert_equal(true,  cookies[1].for_domain)
      end

      assert_equal(3, @jar.cookies(url).length)
    end

    def test_save_load_signature
      Dir.mktmpdir { |dir|
        filename = File.join(dir, "cookies.yml")

        @jar.save(filename, :format => :cookiestxt, :session => true)
        @jar.save(filename, :format => :cookiestxt, :session => true)
        @jar.save(filename, :format => :cookiestxt)
        @jar.save(filename, :cookiestxt, :session => true)
        @jar.save(filename, :cookiestxt)
        @jar.save(filename, HTTP::CookieJar::CookiestxtSaver)
        @jar.save(filename, HTTP::CookieJar::CookiestxtSaver.new)
        @jar.save(filename, :session => true)
        @jar.save(filename)

        assert_raises(ArgumentError) {
          @jar.save()
        }
        assert_raises(ArgumentError) {
          @jar.save(filename, :nonexistent)
        }
        assert_raises(TypeError) {
          @jar.save(filename, { :format => :cookiestxt }, { :session => true })
        }
        assert_raises(ArgumentError) {
          @jar.save(filename, :cookiestxt, { :session => true }, { :format => :cookiestxt })
        }

        @jar.load(filename, :format => :cookiestxt, :linefeed => "\n")
        @jar.load(filename, :format => :cookiestxt, :linefeed => "\n")
        @jar.load(filename, :format => :cookiestxt)
        @jar.load(filename, HTTP::CookieJar::CookiestxtSaver)
        @jar.load(filename, HTTP::CookieJar::CookiestxtSaver.new)
        @jar.load(filename, :cookiestxt, :linefeed => "\n")
        @jar.load(filename, :cookiestxt)
        @jar.load(filename, :linefeed => "\n")
        @jar.load(filename)
        assert_raises(ArgumentError) {
          @jar.load()
        }
        assert_raises(ArgumentError) {
          @jar.load(filename, :nonexistent)
        }
        assert_raises(TypeError) {
          @jar.load(filename, { :format => :cookiestxt }, { :linefeed => "\n" })
        }
        assert_raises(ArgumentError) {
          @jar.load(filename, :cookiestxt, { :linefeed => "\n" }, { :format => :cookiestxt })
        }
      }
    end

    def test_save_session_cookies_yaml
      url = URI 'http://rubyforge.org/'

      # Add one cookie with an expiration date in the future
      cookie = HTTP::Cookie.new(cookie_values)
      s_cookie = HTTP::Cookie.new(cookie_values(:name => 'Bar',
          :expires => nil))

      @jar.add(cookie)
      @jar.add(s_cookie)
      @jar.add(HTTP::Cookie.new(cookie_values(:name => 'Baz')))

      assert_equal(3, @jar.cookies(url).length)

      Dir.mktmpdir do |dir|
        @jar.save(File.join(dir, "cookies.yml"), :format => :yaml, :session => true)

        @jar2.load(File.join(dir, "cookies.yml"))
        assert_equal(3, @jar2.cookies(url).length)
      end

      assert_equal(3, @jar.cookies(url).length)
    end

    def test_save_and_read_cookiestxt
      url = URI 'http://rubyforge.org/foo/'

      # Add one cookie with an expiration date in the future
      cookie = HTTP::Cookie.new(cookie_values)
      expires = cookie.expires
      s_cookie = HTTP::Cookie.new(cookie_values(:name => 'Bar',
          :expires => nil))
      cookie2 = HTTP::Cookie.new(cookie_values(:name => 'Baz',
          :value => 'Foo#Baz',
          :path => '/foo/',
          :for_domain => false))
      h_cookie = HTTP::Cookie.new(cookie_values(:name => 'Quux',
          :value => 'Foo#Quux',
          :httponly => true))
      ma_cookie = HTTP::Cookie.new(cookie_values(:name => 'Maxage',
          :value => 'Foo#Maxage',
          :max_age => 15000))
      @jar.add(cookie)
      @jar.add(s_cookie)
      @jar.add(cookie2)
      @jar.add(h_cookie)
      @jar.add(ma_cookie)

      assert_equal(5, @jar.cookies(url).length)

      Dir.mktmpdir do |dir|
        filename = File.join(dir, "cookies.txt")
        @jar.save(filename, :cookiestxt)

        content = File.read(filename)

        filename2 = File.join(dir, "cookies2.txt")
        open(filename2, 'w') { |w|
          w.puts '# HTTP Cookie File'
          @jar.save(w, :cookiestxt, :header => nil)
        }
        assert_equal content, File.read(filename2)

        assert_match(/^\.rubyforge\.org\t.*\tFoo\t/, content)
        assert_match(/^rubyforge\.org\t.*\tBaz\t/, content)
        assert_match(/^#HttpOnly_\.rubyforge\.org\t/, content)

        @jar2.load(filename, :cookiestxt) # HACK test the format
        cookies = @jar2.cookies(url)
        assert_equal(4, cookies.length)
        cookies.each { |cookie|
          case cookie.name
          when 'Foo'
            assert_equal 'Bar', cookie.value
            assert_equal expires, cookie.expires
            assert_equal 'rubyforge.org', cookie.domain
            assert_equal true, cookie.for_domain
            assert_equal '/', cookie.path
            assert_equal false, cookie.httponly?
          when 'Baz'
            assert_equal 'Foo#Baz', cookie.value
            assert_equal 'rubyforge.org', cookie.domain
            assert_equal false, cookie.for_domain
            assert_equal '/foo/', cookie.path
            assert_equal false, cookie.httponly?
          when 'Quux'
            assert_equal 'Foo#Quux', cookie.value
            assert_equal expires, cookie.expires
            assert_equal 'rubyforge.org', cookie.domain
            assert_equal true, cookie.for_domain
            assert_equal '/', cookie.path
            assert_equal true, cookie.httponly?
          when 'Maxage'
            assert_equal 'Foo#Maxage', cookie.value
            assert_equal nil, cookie.max_age
            assert_in_delta ma_cookie.expires, cookie.expires, 1
          else
            raise
          end
        }
      end

      assert_equal(5, @jar.cookies(url).length)
    end

    def test_load_yaml_mechanize
      @jar.load(test_file('mechanize.yml'), :yaml)

      assert_equal 4, @jar.to_a.size

      com_nid, com_pref = @jar.cookies('http://www.google.com/')

      assert_equal 'NID', com_nid.name
      assert_equal 'Sun, 23 Sep 2063 08:20:15 GMT', com_nid.expires.httpdate
      assert_equal 'google.com', com_nid.domain_name.hostname

      assert_equal 'PREF', com_pref.name
      assert_equal 'Tue, 24 Mar 2065 08:20:15 GMT', com_pref.expires.httpdate
      assert_equal 'google.com', com_pref.domain_name.hostname

      cojp_nid, cojp_pref = @jar.cookies('http://www.google.co.jp/')

      assert_equal 'NID', cojp_nid.name
      assert_equal 'Sun, 23 Sep 2063 08:20:16 GMT', cojp_nid.expires.httpdate
      assert_equal 'google.co.jp', cojp_nid.domain_name.hostname

      assert_equal 'PREF', cojp_pref.name
      assert_equal 'Tue, 24 Mar 2065 08:20:16 GMT', cojp_pref.expires.httpdate
      assert_equal 'google.co.jp', cojp_pref.domain_name.hostname
    end

    def test_expire_cookies
      url = URI 'http://rubyforge.org/'

      # Add one cookie with an expiration date in the future
      cookie = HTTP::Cookie.new(cookie_values)
      @jar.add(cookie)
      assert_equal(1, @jar.cookies(url).length)

      # Add a second cookie
      @jar.add(HTTP::Cookie.new(cookie_values(:name => 'Baz')))
      assert_equal(2, @jar.cookies(url).length)

      # Make sure we can get the cookie from different paths
      assert_equal(2, @jar.cookies(URI('http://rubyforge.org/login')).length)

      # Expire the first cookie
      @jar.add(HTTP::Cookie.new(cookie_values(:expires => Time.now - (10 * 86400))))
      assert_equal(1, @jar.cookies(url).length)

      # Expire the second cookie
      @jar.add(HTTP::Cookie.new(cookie_values( :name => 'Baz', :expires => Time.now - (10 * 86400))))
      assert_equal(0, @jar.cookies(url).length)
    end

    def test_session_cookies
      values = cookie_values(:expires => nil)
      url = URI 'http://rubyforge.org/'

      # Add one cookie with an expiration date in the future
      cookie = HTTP::Cookie.new(values)
      @jar.add(cookie)
      assert_equal(1, @jar.cookies(url).length)

      # Add a second cookie
      @jar.add(HTTP::Cookie.new(values.merge(:name => 'Baz')))
      assert_equal(2, @jar.cookies(url).length)

      # Make sure we can get the cookie from different paths
      assert_equal(2, @jar.cookies(URI('http://rubyforge.org/login')).length)

      # Expire the first cookie
      @jar.add(HTTP::Cookie.new(values.merge(:expires => Time.now - (10 * 86400))))
      assert_equal(1, @jar.cookies(url).length)

      # Expire the second cookie
      @jar.add(HTTP::Cookie.new(values.merge(:name => 'Baz', :expires => Time.now - (10 * 86400))))
      assert_equal(0, @jar.cookies(url).length)

      # When given a URI with a blank path, CookieJar#cookies should return
      # cookies with the path '/':
      url = URI 'http://rubyforge.org'
      assert_equal '', url.path
      assert_equal(0, @jar.cookies(url).length)
      # Now add a cookie with the path set to '/':
      @jar.add(HTTP::Cookie.new(values.merge(:name => 'has_root_path', :path => '/')))
      assert_equal(1, @jar.cookies(url).length)
    end

    def test_paths
      url = URI 'http://rubyforge.org/login'
      values = cookie_values(:path => "/login", :expires => nil, :origin => url)

      # Add one cookie with an expiration date in the future
      cookie = HTTP::Cookie.new(values)
      @jar.add(cookie)
      assert_equal(1, @jar.cookies(url).length)

      # Add a second cookie
      @jar.add(HTTP::Cookie.new(values.merge( :name => 'Baz' )))
      assert_equal(2, @jar.cookies(url).length)

      # Make sure we don't get the cookie in a different path
      assert_equal(0, @jar.cookies(URI('http://rubyforge.org/hello')).length)
      assert_equal(0, @jar.cookies(URI('http://rubyforge.org/')).length)

      # Expire the first cookie
      @jar.add(HTTP::Cookie.new(values.merge( :expires => Time.now - (10 * 86400))))
      assert_equal(1, @jar.cookies(url).length)

      # Expire the second cookie
      @jar.add(HTTP::Cookie.new(values.merge( :name => 'Baz',
            :expires => Time.now - (10 * 86400))))
      assert_equal(0, @jar.cookies(url).length)
    end

    def test_ssl_cookies
      # thanks to michal "ocher" ochman for reporting the bug responsible for this test.
      values = cookie_values(:expires => nil)
      values_ssl = values.merge(:name => 'Baz', :domain => "#{values[:domain]}:443")
      url = URI 'https://rubyforge.org/login'

      cookie = HTTP::Cookie.new(values)
      @jar.add(cookie)
      assert_equal(1, @jar.cookies(url).length, "did not handle SSL cookie")

      cookie = HTTP::Cookie.new(values_ssl)
      @jar.add(cookie)
      assert_equal(2, @jar.cookies(url).length, "did not handle SSL cookie with :443")
    end

    def test_secure_cookie
      nurl = URI 'http://rubyforge.org/login'
      surl = URI 'https://rubyforge.org/login'

      nncookie = HTTP::Cookie.new(cookie_values(:name => 'Foo1', :origin => nurl))
      sncookie = HTTP::Cookie.new(cookie_values(:name => 'Foo1', :origin => surl))
      nscookie = HTTP::Cookie.new(cookie_values(:name => 'Foo2', :secure => true, :origin => nurl))
      sscookie = HTTP::Cookie.new(cookie_values(:name => 'Foo2', :secure => true, :origin => surl))

      @jar.add(nncookie)
      @jar.add(sncookie)
      @jar.add(nscookie)
      @jar.add(sscookie)

      assert_equal('Foo1',      @jar.cookies(nurl).map { |c| c.name }.sort.join(' ') )
      assert_equal('Foo1 Foo2', @jar.cookies(surl).map { |c| c.name }.sort.join(' ') )
    end

    def test_delete
      cookie1 = HTTP::Cookie.new(cookie_values)
      cookie2 = HTTP::Cookie.new(:name => 'Foo', :value => '',
                                 :domain => 'rubyforge.org',
                                 :for_domain => false,
                                 :path => '/')
      cookie3 = HTTP::Cookie.new(:name => 'Foo', :value => '',
                                 :domain => 'rubyforge.org',
                                 :for_domain => true,
                                 :path => '/')

      @jar.add(cookie1)
      @jar.delete(cookie2)

      if mozilla_store?
        assert_equal(1, @jar.to_a.length)
        @jar.delete(cookie3)
      end

      assert_equal(0, @jar.to_a.length)
    end

    def test_accessed_at
      orig = HTTP::Cookie.new(cookie_values(:expires => nil))
      @jar.add(orig)

      time = orig.accessed_at

      assert_in_delta 1.0, time, Time.now, "accessed_at is initialized to the current time"

      cookie, = @jar.to_a

      assert_equal time, cookie.accessed_at, "accessed_at is not updated by each()"

      cookie, = @jar.cookies("http://rubyforge.org/")

      assert_send [cookie.accessed_at, :>, time], "accessed_at is not updated by each(url)"
    end

    def test_max_cookies
      slimit = HTTP::Cookie::MAX_COOKIES_TOTAL + @gc_threshold

      limit_per_domain = HTTP::Cookie::MAX_COOKIES_PER_DOMAIN
      uri = URI('http://www.example.org/')
      date = Time.at(Time.now.to_i + 86400)
      (1..(limit_per_domain + 1)).each { |i|
        @jar << HTTP::Cookie.new(cookie_values(
            :name => 'Foo%d' % i,
            :value => 'Bar%d' % i,
            :domain => uri.host,
            :for_domain => true,
            :path => '/dir%d/' % (i / 2),
            :origin => uri
            )).tap { |cookie|
          cookie.created_at = i == 42 ? date - i : date
        }
      }
      assert_equal limit_per_domain + 1, @jar.to_a.size
      @jar.cleanup
      count = @jar.to_a.size
      assert_equal limit_per_domain, count
      assert_equal [*1..(limit_per_domain + 1)] - [42], @jar.map { |cookie|
        cookie.name[/(\d+)$/].to_i
      }.sort

      hlimit = HTTP::Cookie::MAX_COOKIES_TOTAL

      n = hlimit / limit_per_domain * 2

      (1..n).each { |i|
        (1..(limit_per_domain + 1)).each { |j|
          uri = URI('http://www%d.example.jp/' % i)
          @jar << HTTP::Cookie.new(cookie_values(
              :name => 'Baz%d' % j,
              :value => 'www%d.example.jp' % j,
              :domain => uri.host,
              :for_domain => true,
              :path => '/dir%d/' % (i / 2),
              :origin => uri
              )).tap { |cookie|
            cookie.created_at = i == j ? date - i : date
          }
          count += 1
        }
      }

      assert_send [count, :>, slimit]
      assert_send [@jar.to_a.size, :<=, slimit]
      @jar.cleanup
      assert_equal hlimit, @jar.to_a.size
      assert_equal false, @jar.any? { |cookie|
        cookie.domain == cookie.value
      }
    end

    def test_parse
      set_cookie = [
        "name=Akinori; Domain=rubyforge.org; Expires=Sun, 08 Aug 2076 19:00:00 GMT; Path=/",
        "country=Japan; Domain=rubyforge.org; Expires=Sun, 08 Aug 2076 19:00:00 GMT; Path=/",
        "city=Tokyo; Domain=rubyforge.org; Expires=Sun, 08 Aug 2076 19:00:00 GMT; Path=/",
      ].join(', ')

      cookies = @jar.parse(set_cookie, 'http://rubyforge.org/')
      assert_equal %w[Akinori Japan Tokyo], cookies.map { |c| c.value }
      assert_equal %w[Tokyo Japan Akinori], @jar.to_a.sort_by { |c| c.name }.map { |c| c.value }
    end

    def test_parse_with_block
      set_cookie = [
        "name=Akinori; Domain=rubyforge.org; Expires=Sun, 08 Aug 2076 19:00:00 GMT; Path=/",
        "country=Japan; Domain=rubyforge.org; Expires=Sun, 08 Aug 2076 19:00:00 GMT; Path=/",
        "city=Tokyo; Domain=rubyforge.org; Expires=Sun, 08 Aug 2076 19:00:00 GMT; Path=/",
      ].join(', ')

      cookies = @jar.parse(set_cookie, 'http://rubyforge.org/') { |c| c.name != 'city' }
      assert_equal %w[Akinori Japan], cookies.map { |c| c.value }
      assert_equal %w[Japan Akinori], @jar.to_a.sort_by { |c| c.name }.map { |c| c.value }
    end

    def test_expire_by_each_and_cleanup
      uri = URI('http://www.example.org/')

      ts = Time.now.to_f
      if ts % 1 > 0.5
        sleep 0.5
        ts += 0.5
      end
      expires = Time.at(ts.floor)
      time = expires

      if mozilla_store?
        # MozillaStore only has the time precision of seconds.
        time = expires
        expires -= 1
      end

      0.upto(2) { |i|
        c = HTTP::Cookie.new('Foo%d' % (3 - i), 'Bar', :expires => expires + i, :origin => uri)
        @jar  << c
        @jar2 << c
      }

      assert_equal %w[Foo1 Foo2], @jar.cookies.map(&:name)
      assert_equal %w[Foo1 Foo2], @jar2.cookies(uri).map(&:name)

      sleep_until time + 1

      assert_equal %w[Foo1], @jar.cookies.map(&:name)
      assert_equal %w[Foo1], @jar2.cookies(uri).map(&:name)

      sleep_until time + 2

      @jar.cleanup
      @jar2.cleanup

      assert_send [@jar,  :empty?]
      assert_send [@jar2, :empty?]
    end
  end

  class WithHashStore < Test::Unit::TestCase
    include CommonTests

    def test_new
      jar = HTTP::CookieJar.new(:store => :hash)
      assert_instance_of HTTP::CookieJar::HashStore, jar.store

      assert_raises(ArgumentError) {
        jar = HTTP::CookieJar.new(:store => :nonexistent)
      }

      jar = HTTP::CookieJar.new(:store => HTTP::CookieJar::HashStore.new)
      assert_instance_of HTTP::CookieJar::HashStore, jar.store

      jar = HTTP::CookieJar.new(:store => HTTP::CookieJar::HashStore)
    end

    def test_clone
      jar = @jar.clone
      assert_not_send [
        @jar.store,
        :equal?,
        jar.store
      ]
      assert_not_send [
        @jar.store.instance_variable_get(:@jar),
        :equal?,
        jar.store.instance_variable_get(:@jar)
      ]
      assert_equal @jar.cookies, jar.cookies
    end
  end

  class WithMozillaStore < Test::Unit::TestCase
    include CommonTests

    def setup
      super(
        { :store => :mozilla, :filename => ":memory:" },
        { :store => :mozilla, :filename => ":memory:" })
    end

    def add_and_delete(jar)
      jar.parse("name=Akinori; Domain=rubyforge.org; Expires=Sun, 08 Aug 2076 19:00:00 GMT; Path=/",
                'http://rubyforge.org/')
      jar.parse("country=Japan; Domain=rubyforge.org; Expires=Sun, 08 Aug 2076 19:00:00 GMT; Path=/",
                'http://rubyforge.org/')
      jar.delete(HTTP::Cookie.new("name", :domain => 'rubyforge.org'))
    end

    def test_clone
      assert_raises(TypeError) {
        @jar.clone
      }
    end

    def test_close
      add_and_delete(@jar)

      assert_not_send [@jar.store, :closed?]
      @jar.store.close
      assert_send [@jar.store, :closed?]
      @jar.store.close	# should do nothing
      assert_send [@jar.store, :closed?]
    end

    def test_finalizer
      db = nil
      loop {
        jar = HTTP::CookieJar.new(:store => :mozilla, :filename => ':memory:')
        add_and_delete(jar)
        db = jar.store.instance_variable_get(:@db)
        class << db
          alias close_orig close
          def close
            STDERR.print "[finalizer is called]"
            STDERR.flush
            close_orig
          end
        end
        break
      }
    end

    def test_upgrade_mozillastore
      Dir.mktmpdir { |dir|
        filename = File.join(dir, 'cookies.sqlite')

        sqlite = SQLite3::Database.new(filename)
        sqlite.execute(<<-'SQL')
          CREATE TABLE moz_cookies (
            id INTEGER PRIMARY KEY,
            name TEXT,
            value TEXT,
            host TEXT,
            path TEXT,
            expiry INTEGER,
            isSecure INTEGER,
            isHttpOnly INTEGER)
        SQL
        sqlite.execute(<<-'SQL')
          PRAGMA user_version = 1
        SQL

        begin
          st_insert = sqlite.prepare(<<-'SQL')
            INSERT INTO moz_cookies (
              id, name, value, host, path, expiry, isSecure, isHttpOnly
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?)
          SQL

          st_insert.execute(1, 'name1', 'value1', '.example.co.jp', '/', 2312085765, 0, 0)
          st_insert.execute(2, 'name1', 'value2', '.example.co.jp', '/', 2312085765, 0, 0)
          st_insert.execute(3, 'name1', 'value3', 'www.example.co.jp', '/', 2312085765, 0, 0)
        ensure
          st_insert.close if st_insert
        end

        sqlite.close
        jar = HTTP::CookieJar.new(:store => :mozilla, :filename => filename)

        assert_equal 2, jar.to_a.size
        assert_equal 2, jar.cookies('http://www.example.co.jp/').size

        cookie, *rest = jar.cookies('http://host.example.co.jp/')
        assert_send [rest, :empty?]
        assert_equal 'value2', cookie.value
      }
    end
  end if begin
    require 'sqlite3'
    true
  rescue LoadError
    STDERR.puts 'sqlite3 missing?'
    false
  end
end
