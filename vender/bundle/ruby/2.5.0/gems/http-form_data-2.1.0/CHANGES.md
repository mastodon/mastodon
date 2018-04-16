## 2.1.0 (2018-03-05)

* [#21](https://github.com/httprb/form_data/pull/21)
  Rewind content at the end of `Readable#to_s`.
  [@janko-m][]

* [#19](https://github.com/httprb/form_data/pull/19)
  Fix buffer encoding.
  [@HoneyryderChuck][]


## 2.0.0 (2017-10-01)

* [#17](https://github.com/httprb/form_data/pull/17)
  Add CRLF character to end of multipart body.
  [@mhickman][]


## 2.0.0.pre2 (2017-05-11)

* [#14](https://github.com/httprb/form_data/pull/14)
  Enable streaming for urlencoded form data.
  [@janko-m][]


## 2.0.0.pre1 (2017-05-10)

* [#12](https://github.com/httprb/form_data.rb/pull/12)
  Enable form data streaming.
  [@janko-m][]


## 1.0.2 (2017-05-08)

* [#5](https://github.com/httprb/form_data.rb/issues/5)
  Allow setting Content-Type non-file parts 
  [@abotalov][]

* [#6](https://github.com/httprb/form_data.rb/issues/6)
  Creation of file parts without filename
  [@abotalov][]

* [#11](https://github.com/httprb/form_data.rb/pull/11)
  Deprecate `HTTP::FormData::File#mime_type`. Use `#content_type` instead.
  [@ixti][]


## 1.0.1 (2015-03-31)

* Fix usage of URI module.


## 1.0.0 (2015-01-04)

* Gem renamed to `http-form_data` as `FormData` is not top-level citizen
  anymore: `FormData -> HTTP::FormData`.


## 0.1.0 (2015-01-02)

* Move repo under `httprb` organization on GitHub.
* Add `nil` support to `FormData#ensure_hash`.


## 0.0.1 (2014-12-15)

* First release ever!

[@ixti]: https://github.com/ixti
[@abotalov]: https://github.com/abotalov
[@janko-m]: https://github.com/janko-m
[@mhickman]: https://github.com/mhickman
[@HoneyryderChuck]: https://github.com/HoneyryderChuck
