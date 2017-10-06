# frozen_string_literal: true

# Adopted rb/spec/test_urls.rb from twitter-text.
# Please contribute new changes of this file to the upstream if they are not specific to Mastodon.

module TestUrls
  VALID = [
    'http://google.com',
    'http://foobar.com/#',
    'http://google.com/#foo',
    'http://google.com/#search?q=iphone%20-filter%3Alinks',
    'http://twitter.com/#search?q=iphone%20-filter%3Alinks',
    'http://somedomain.com/index.php?path=/abc/def/',
    'http://www.boingboing.net/2007/02/14/katamari_damacy_phon.html',
    'http://somehost.com:3000',
    'http://xo.com/~matthew+%-x',
    'http://en.wikipedia.org/wiki/Primer_(film)',
    'http://www.ams.org/bookstore-getitem/item=mbk-59',
    'http://chilp.it/?77e8fd',
    'http://tell.me/why',
    'http://longtlds.info',
    'http://✪df.ws/ejp',
    'http://日本.com',
    'http://search.twitter.com/search?q=avro&lang=en',
    'http://mrs.domain-dash.biz',
    'http://x.com/has/one/char/domain',
    'http://t.co/nwcLTFF',
    'http://sub_domain-dash.twitter.com',
    'http://a.b.cd',
    'http://a_b.c-d.com',
    'http://a-b.b.com',
    'http://twitter-dash.com',
    'http://msdn.microsoft.com/ja-jp/library/system.net.httpwebrequest(v=VS.100).aspx',
    'www.foobar.com',
    'WWW.FOOBAR.COM',
    'www.foobar.co.jp',
    'http://t.co',
    't.co/nwcLTFF',
    'http://foobar.みんな',
    'http://foobar.中国',
    'http://foobar.پاکستان',
    'https://www.youtube.com/playlist?list=PL0ZPu8XSRTB7wZzn0mLHMvyzVFeRxbWn-'
  ] unless defined?(TestUrls::VALID)

  INVALID = [
    'http://no-tld',
    'http://tld-too-short.x',
    'http://-doman_dash.com',
    'http://_leadingunderscore.twitter.com',
    'http://trailingunderscore_.twitter.com',
    'http://-leadingdash.twitter.com',
    'http://trailingdash-.twitter.com',
    'http://-leadingdash.com',
    'http://trailingdash-.com',
    'http://no_underscores.com',
    'http://test.c_o_m',
    'http://test.c-o-m',
    "http://twitt#{[0x202A].pack('U')}er.com",
    "http://twitt#{[0x202B].pack('U')}er.com",
    "http://twitt#{[0x202C].pack('U')}er.com",
    "http://twitt#{[0x202D].pack('U')}er.com",
    "http://twitt#{[0x202E].pack('U')}er.com"
  ] unless defined?(TestUrls::INVALID)
end
