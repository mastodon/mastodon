# -*- coding: utf-8 -*-
require 'helper'
require 'ipaddr'

class TestDomainName < Test::Unit::TestCase
  test "raise ArgumentError if hostname starts with a dot" do
    [
      # Leading dot.
      '.com',
      '.example',
      '.example.com',
      '.example.example',
    ].each { |hostname|
      assert_raises(ArgumentError) { DomainName.new(hostname) }
    }
  end

  test "accept a String-alike for initialization" do
    Object.new.tap { |obj|
      def obj.to_str
        "Example.org"
      end
      assert_equal "example.org", DomainName.new(obj).hostname
    }

    Object.new.tap { |obj|
      def obj.to_str
        123
      end
      assert_raises(TypeError) { DomainName.new(obj) }
    }

    Object.new.tap { |obj|
      assert_raises(TypeError) { DomainName.new(obj) }
    }
  end

  test "parse canonical domain names correctly" do
    [
      # Mixed case.
      ['COM', nil, false, 'com', true],
      ['example.COM', 'example.com', true, 'com', true],
      ['WwW.example.COM', 'example.com', true, 'com', true],
      # Unlisted TLD.
      ['example', 'example', false, 'example', false],
      ['example.example', 'example.example', false, 'example', false],
      ['b.example.example', 'example.example', false, 'example', false],
      ['a.b.example.example', 'example.example', false, 'example', false],
      # Listed, but non-Internet, TLD.
      ['local', 'local', false, 'local', false],
      ['example.local', 'example.local', false, 'local', false],
      ['b.example.local', 'example.local', false, 'local', false],
      ['a.b.example.local', 'example.local', false, 'local', false],
      # TLD with only 1 rule.
      ['biz', nil, false, 'biz', true],
      ['domain.biz', 'domain.biz', true, 'biz', true],
      ['b.domain.biz', 'domain.biz', true, 'biz', true],
      ['a.b.domain.biz', 'domain.biz', true, 'biz', true],
      # TLD with some 2-level rules.
      ['com', nil, false, 'com', true],
      ['example.com', 'example.com', true, 'com', true],
      ['b.example.com', 'example.com', true, 'com', true],
      ['a.b.example.com', 'example.com', true, 'com', true],
      ['uk.com', nil, false, 'com', true],
      ['example.uk.com', 'example.uk.com', true, 'com', true],
      ['b.example.uk.com', 'example.uk.com', true, 'com', true],
      ['a.b.example.uk.com', 'example.uk.com', true, 'com', true],
      ['test.ac', 'test.ac', true, 'ac', true],
      # TLD with only 1 (wildcard) rule.
      ['bd', nil, false, 'bd', true],
      ['c.bd', nil, false, 'bd', true],
      ['b.c.bd', 'b.c.bd', true, 'bd', true],
      ['a.b.c.bd', 'b.c.bd', true, 'bd', true],
      # More complex TLD.
      ['jp', nil, false, 'jp', true],
      ['test.jp', 'test.jp', true, 'jp', true],
      ['www.test.jp', 'test.jp', true, 'jp', true],
      ['ac.jp', nil, false, 'jp', true],
      ['test.ac.jp', 'test.ac.jp', true, 'jp', true],
      ['www.test.ac.jp', 'test.ac.jp', true, 'jp', true],
      ['kyoto.jp', nil, false, 'jp', true],
      ['test.kyoto.jp', 'test.kyoto.jp', true, 'jp', true],
      ['ide.kyoto.jp', nil, false, 'jp', true],
      ['b.ide.kyoto.jp', 'b.ide.kyoto.jp', true, 'jp', true],
      ['a.b.ide.kyoto.jp', 'b.ide.kyoto.jp', true, 'jp', true],
      ['c.kobe.jp', nil, false, 'jp', true],
      ['b.c.kobe.jp', 'b.c.kobe.jp', true, 'jp', true],
      ['a.b.c.kobe.jp', 'b.c.kobe.jp', true, 'jp', true],
      ['city.kobe.jp', 'city.kobe.jp', true, 'jp', true],
      ['www.city.kobe.jp', 'city.kobe.jp', true, 'jp', true],
      # TLD with a wildcard rule and exceptions.
      ['ck', nil, false, 'ck', true],
      ['test.ck', nil, false, 'ck', true],
      ['b.test.ck', 'b.test.ck', true, 'ck', true],
      ['a.b.test.ck', 'b.test.ck', true, 'ck', true],
      ['www.ck', 'www.ck', true, 'ck', true],
      ['www.www.ck', 'www.ck', true, 'ck', true],
      # US K12.
      ['us', nil, false, 'us', true],
      ['test.us', 'test.us', true, 'us', true],
      ['www.test.us', 'test.us', true, 'us', true],
      ['ak.us', nil, false, 'us', true],
      ['test.ak.us', 'test.ak.us', true, 'us', true],
      ['www.test.ak.us', 'test.ak.us', true, 'us', true],
      ['k12.ak.us', nil, false, 'us', true],
      ['test.k12.ak.us', 'test.k12.ak.us', true, 'us', true],
      ['www.test.k12.ak.us', 'test.k12.ak.us', true, 'us', true],
      # IDN labels. (modified; currently DomainName always converts U-labels to A-labels)
      ['食狮.com.cn', 'xn--85x722f.com.cn', true, 'cn', true],
      ['食狮.公司.cn', 'xn--85x722f.xn--55qx5d.cn', true, 'cn', true],
      ['www.食狮.公司.cn', 'xn--85x722f.xn--55qx5d.cn', true, 'cn', true],
      ['shishi.公司.cn', 'shishi.xn--55qx5d.cn', true, 'cn', true],
      ['公司.cn', nil, false, 'cn', true],
      ['食狮.中国', 'xn--85x722f.xn--fiqs8s', true, 'xn--fiqs8s', true],
      ['www.食狮.中国', 'xn--85x722f.xn--fiqs8s', true, 'xn--fiqs8s', true],
      ['shishi.中国', 'shishi.xn--fiqs8s', true, 'xn--fiqs8s', true],
      ['中国', nil, false, 'xn--fiqs8s', true],
      # Same as above, but punycoded.
      ['xn--85x722f.com.cn', 'xn--85x722f.com.cn', true, 'cn', true],
      ['xn--85x722f.xn--55qx5d.cn', 'xn--85x722f.xn--55qx5d.cn', true, 'cn', true],
      ['www.xn--85x722f.xn--55qx5d.cn', 'xn--85x722f.xn--55qx5d.cn', true, 'cn', true],
      ['shishi.xn--55qx5d.cn', 'shishi.xn--55qx5d.cn', true, 'cn', true],
      ['xn--55qx5d.cn', nil, false, 'cn', true],
      ['xn--85x722f.xn--fiqs8s', 'xn--85x722f.xn--fiqs8s', true, 'xn--fiqs8s', true],
      ['www.xn--85x722f.xn--fiqs8s', 'xn--85x722f.xn--fiqs8s', true, 'xn--fiqs8s', true],
      ['shishi.xn--fiqs8s', 'shishi.xn--fiqs8s', true, 'xn--fiqs8s', true],
      ['xn--fiqs8s', nil, false, 'xn--fiqs8s', true],
    ].each { |hostname, domain, canonical, tld, canonical_tld|
      dn = DomainName.new(hostname)
      assert_equal(domain, dn.domain, hostname + ':domain')
      assert_equal(canonical, dn.canonical?, hostname + ':canoninal?')
      assert_equal(tld, dn.tld, hostname + ':tld')
      assert_equal(canonical_tld, dn.canonical_tld?, hostname + ':canoninal_tld?')
    }
  end

  test "compare hostnames correctly" do
    [
      ["foo.com", "abc.foo.com", 1],
      ["COM", "abc.foo.com", 1],
      ["abc.def.foo.com", "foo.com", -1],
      ["abc.def.foo.com", "ABC.def.FOO.com", 0],
      ["abc.def.foo.com", "bar.com", nil],
    ].each { |x, y, v|
      dx, dy = DomainName(x), DomainName(y)
      [
        [dx, y, v],
        [dx, dy, v],
        [dy, x, v ? -v : v],
        [dy, dx, v ? -v : v],
      ].each { |a, b, expected|
        assert_equal expected, a <=> b
        case expected
        when 1
          assert_equal(true,  a >  b)
          assert_equal(true,  a >= b)
          assert_equal(false, a == b)
          assert_equal(false, a <= b)
          assert_equal(false, a <  b)
        when -1
          assert_equal(true,  a <  b)
          assert_equal(true,  a <= b)
          assert_equal(false, a == b)
          assert_equal(false, a >= b)
          assert_equal(false, a >  b)
        when 0
          assert_equal(false, a <  b)
          assert_equal(true,  a <= b)
          assert_equal(true,  a == b)
          assert_equal(true,  a >= b)
          assert_equal(false, a >  b)
        when nil
          assert_equal(nil,   a <  b)
          assert_equal(nil,   a <= b)
          assert_equal(false, a == b)
          assert_equal(nil,   a >= b)
          assert_equal(nil,   a >  b)
        end
      }
    }
  end

  test "check cookie domain correctly" do
    {
      'com' => [
        ['com', false],
        ['example.com', false],
        ['foo.example.com', false],
        ['bar.foo.example.com', false],
      ],

      'example.com' => [
        ['com', false],
        ['example.com', true],
        ['foo.example.com', false],
        ['bar.foo.example.com', false],
      ],

      'foo.example.com' => [
        ['com', false],
        ['example.com', true],
        ['foo.example.com', true],
        ['foo.Example.com', true],
        ['bar.foo.example.com', false],
        ['bar.Foo.Example.com', false],
      ],

      'b.sapporo.jp' => [
        ['jp', false],
        ['sapporo.jp', false],
        ['b.sapporo.jp', false],
        ['a.b.sapporo.jp', false],
      ],

      'b.c.sapporo.jp' => [
        ['jp', false],
        ['sapporo.jp', false],
        ['c.sapporo.jp', false],
        ['b.c.sapporo.jp', true],
        ['a.b.c.sapporo.jp', false],
      ],

      'b.c.d.sapporo.jp' => [
        ['jp', false],
        ['sapporo.jp', false],
        ['d.sapporo.jp', false],
        ['c.d.sapporo.jp', true],
        ['b.c.d.sapporo.jp', true],
        ['a.b.c.d.sapporo.jp', false],
      ],

      'city.sapporo.jp' => [
        ['jp', false],
        ['sapporo.jp', false],
        ['city.sapporo.jp', true],
        ['a.city.sapporo.jp', false],
      ],

      'b.city.sapporo.jp' => [
        ['jp', false],
        ['sapporo.jp', false],
        ['city.sapporo.jp', true],
        ['b.city.sapporo.jp', true],
        ['a.b.city.sapporo.jp', false],
      ],
    }.each_pair { |host, pairs|
      dn = DomainName(host)
      assert_equal(true, dn.cookie_domain?(host.upcase, true),     dn.to_s)
      assert_equal(true, dn.cookie_domain?(host.downcase, true),   dn.to_s)
      assert_equal(false, dn.cookie_domain?("www." << host, true), dn.to_s)
      pairs.each { |domain, expected|
        assert_equal(expected, dn.cookie_domain?(domain),             "%s - %s" % [dn.to_s, domain])
        assert_equal(expected, dn.cookie_domain?(DomainName(domain)), "%s - %s" % [dn.to_s, domain])
      }
    }
  end

  test "parse IPv4 addresseses" do
    a = '192.168.10.20'
    dn = DomainName(a)
    assert_equal(a, dn.hostname)
    assert_equal(true, dn.ipaddr?)
    assert_equal(IPAddr.new(a), dn.ipaddr)
    assert_equal(true, dn.cookie_domain?(a))
    assert_equal(true, dn.cookie_domain?(a, true))
    assert_equal(true, dn.cookie_domain?(dn))
    assert_equal(true, dn.cookie_domain?(dn, true))
    assert_equal(false, dn.cookie_domain?('168.10.20'))
    assert_equal(false, dn.cookie_domain?('20'))
    assert_equal(nil, dn.superdomain)
  end

  test "parse IPv6 addresseses" do
    a = '2001:200:dff:fff1:216:3eff:feb1:44d7'
    b = '2001:0200:0dff:fff1:0216:3eff:feb1:44d7'
    [b, b.upcase, "[#{b}]", "[#{b.upcase}]"].each { |host|
      dn = DomainName(host)
      assert_equal("[#{a}]", dn.uri_host)
      assert_equal(a, dn.hostname)
      assert_equal(true, dn.ipaddr?)
      assert_equal(IPAddr.new(a), dn.ipaddr)
      assert_equal(true, dn.cookie_domain?(host))
      assert_equal(true, dn.cookie_domain?(host, true))
      assert_equal(true, dn.cookie_domain?(dn))
      assert_equal(true, dn.cookie_domain?(dn, true))
      assert_equal(true, dn.cookie_domain?(a))
      assert_equal(true, dn.cookie_domain?(a, true))
      assert_equal(nil, dn.superdomain)
    }
  end

  test "get superdomain" do
    [
      %w[www.sub.example.local sub.example.local example.local local],
      %w[www.sub.example.com sub.example.com example.com com],
    ].each { |domain, *superdomains|
      dn = DomainName(domain)
      superdomains.each { |superdomain|
        sdn = DomainName(superdomain)
        assert_equal sdn, dn.superdomain
        dn = sdn
      }
      assert_equal nil, dn.superdomain
    }
  end

  test "have idn methods" do
    dn = DomainName("金八先生.B組.3年.日本語ドメイン名Example.日本")

    assert_equal "xn--44q1cv48kq8x.xn--b-gf6c.xn--3-pj3b.xn--example-6q4fyliikhk162btq3b2zd4y2o.xn--wgv71a", dn.hostname
    assert_equal "金八先生.b組.3年.日本語ドメイン名example.日本", dn.hostname_idn
    assert_equal "xn--example-6q4fyliikhk162btq3b2zd4y2o.xn--wgv71a", dn.domain
    assert_equal "日本語ドメイン名example.日本", dn.domain_idn
    assert_equal "xn--wgv71a", dn.tld
    assert_equal "日本", dn.tld_idn
  end
end
