# 1.8.2 / 2018-01-29

## Security Notes

[MRI] The update of vendored libxml2 from 2.9.5 to 2.9.7 addresses at least one published vulnerability, CVE-2017-15412. [#1714 has complete details]


## Dependencies

* [MRI] libxml2 is updated from 2.9.5 to 2.9.7
* [MRI] libxml2 is updated from 1.1.30 to 1.1.32


## Features

* [MRI] OpenBSD installation should be a bit easier now. [#1685] (Thanks, @jeremyevans!)
* [MRI] Cross-built Windows gems now support Ruby 2.5


## Bug fixes

* Node#serialize once again returns UTF-8-encoded strings. [#1659]
* [JRuby] made SAX parsing of characters consistent with C implementation [#1676] (Thanks, @andrew-aladev!)
* [MRI] Predefined entities, when inspected, no longer cause a segfault. [#1238]


# 1.8.1 / 2017-09-19

## Dependencies

* [MRI] libxml2 is updated from 2.9.4 to 2.9.5.
* [MRI] libxslt is updated from 1.1.29 to 1.1.30.
* [MRI] optional dependency on the pkg-config gem has had its constraint loosened to `~> 1.1` (from `~> 1.1.7`). [#1660]
* [MRI] Upgrade mini_portile2 dependency from `~> 2.2.0` to `~> 2.3.0`, which will validate checksums on the vendored libxml2 and libxslt tarballs before using them.


## Bugs

* NodeSet#first with an integer argument longer than the length of the NodeSet now correctly clamps the length of the returned NodeSet to the original length. [#1650] (Thanks, @Derenge!)
* [MRI] Ensure CData.new raises TypeError if the `content` argument is not implicitly convertible into a string. [#1669]


# 1.8.0 / 2017-06-04

## Backwards incompatibilities

This release ends support for Ruby 2.1 on Windows in the `x86-mingw32` and `x64-mingw32` platform gems (containing pre-compiled DLLs). Official support ended for Ruby 2.1 on 2017-04-01.

Please note that this deprecation note only applies to the precompiled Windows gems. Ruby 2.1 continues to be supported (for now) in the default gem when compiled on installation.


## Dependencies

* [Windows] Upgrade iconv from 1.14 to 1.15 (unless --use-system-libraries)
* [Windows] Upgrade zlib from 1.2.8 to 1.2.11 (unless --use-system-libraries)
* [MRI] Upgrade rake-compiler dependency from 0.9.2 to 1.0.3
* [MRI] Upgrade mini-portile2 dependency from `~> 2.1.0` to `~> 2.2.0`


## Compatibility notes

* [JRuby] Removed support for `jruby --1.8` code paths. [#1607] (Thanks, @kares!)
* [MRI Windows] Retrieve zlib source from http://zlib.net/fossils to avoid deprecation issues going forward. See #1632 for details around this problem.


## Features

* NodeSet#clone is not an alias for NodeSet#dup [#1503] (Thanks, @stephankaag!)
* Allow Processing Instructions and Comments as children of a document root. [#1033] (Thanks, @windwiny!)
* [MRI] PushParser#replace_entities and #replace_entities= will control whether entities are replaced or not. [#1017] (Thanks, @spraints!)
* [MRI] SyntaxError#to_s now includes line number, column number, and log level if made available by the parser. [#1304, #1637] (Thanks, @spk and @ccarruitero!)
* [MRI] Cross-built Windows gems now support Ruby 2.4
* [MRI] Support for frozen string literals. [#1413]
* [MRI] Support for installing Nokogiri on a machine in FIPS-enabled mode [#1544]
* [MRI] Vendored libraries are verified with SHA-256 hashes (formerly some MD5 hashes were used) [#1544]
* [JRuby] (performance) remove unnecessary synchronization of class-cache [#1563] (Thanks, @kares!)
* [JRuby] (performance) remove unnecessary cloning of objects in XPath searches [#1563] (Thanks, @kares!)
* [JRuby] (performance) more performance improvements, particularly in XPath, Reader, XmlNode, and XmlNodeSet [#1597] (Thanks, @kares!)


## Bugs

* HTML::SAX::Parser#parse_io now correctly parses HTML and not XML [#1577] (Thanks for the test case, @gregors!)
* Support installation on systems with a `lib64` site config. [#1562]
* [MRI] on OpenBSD, do not require gcc if using system libraries [#1515] (Thanks, @jeremyevans!)
* [MRI] XML::Attr.new checks type of Document arg to prevent segfaults. [#1477]
* [MRI] Prefer xmlCharStrdup (and friends) to strdup (and friends), which can cause problems on some platforms. [#1517] (Thanks, @jeremy!)
* [JRuby] correctly append a text node before another text node [#1318] (Thanks, @jkraemer!)
* [JRuby] custom xpath functions returning an integer now work correctly [#1595] (Thanks, @kares!)
* [JRuby] serializing (`#to_html`, `#to_s`, et al) a document with explicit encoding now works correctly. [#1281, #1440] (Thanks, @kares!)
* [JRuby] XML::Reader now returns parse errors [#1586] (Thanks, @kares!)
* [JRuby] Empty NodeSets are now decorated properly. [#1319] (Thanks, @kares!)
* [JRuby] Merged nodes no longer results in Java exceptions during XPath queries. [#1320] (Thanks, @kares!)


# 1.7.2 / 2017-05-09

## Security Notes

[MRI] Upstream libxslt patches are applied to the vendored libxslt 1.1.29 which address CVE-2017-5029 and CVE-2016-4738.

For more information:

* https://github.com/sparklemotion/nokogiri/issues/1634
* http://people.canonical.com/~ubuntu-security/cve/2017/CVE-2017-5029.html
* http://people.canonical.com/~ubuntu-security/cve/2016/CVE-2016-4738.html


# 1.7.1 / 2017-03-19

## Security Notes

[MRI] Upstream libxml2 patches are applied to the vendored libxml 2.9.4 which address CVE-2016-4658 and CVE-2016-5131.

For more information:

* https://github.com/sparklemotion/nokogiri/issues/1615
* http://people.canonical.com/~ubuntu-security/cve/2016/CVE-2016-4658.html
* http://people.canonical.com/~ubuntu-security/cve/2016/CVE-2016-5131.html


# 1.7.0.1 / 2017-01-04

## Bugs

* Fix OpenBSD support. (#1569) (related to #1543)


# 1.7.0 / 2016-12-26

## Features

* Remove deprecation warnings in Ruby 2.4.0 (#1545) (Thanks, @matthewd!)
* Support egcc compiler on OpenBSD (#1543) (Thanks, @frenkel and @knu!)


## Backwards incompatibilities.

This release ends support for:

* Ruby 1.9.2, for which official support ended on 2014-07-31
* Ruby 1.9.3, for which official support ended on 2015-02-23
* Ruby 2.0.0, for which official support ended on 2016-02-24
* MacRuby, which hasn't been actively supported since 2015-01-13 (see https://github.com/MacRuby/MacRuby/commit/f76b9d6e99c18236db617e8aceb12c27d593a483)


# 1.6.8.1 / 2016-10-03

## Dependency License Notes

Removes required dependency on the `pkg-config` gem. This dependency
was introduced in v1.6.8 and, because it's distributed under LGPL, was
objectionable to many Nokogiri users (#1488, #1496).

This version makes `pkg-config` an optional dependency. If it's
installed, it's used; but otherwise Nokogiri will attempt to work
around its absence.


# 1.6.8 / 2016-06-06

## Security Notes

[MRI] Bundled libxml2 is upgraded to 2.9.4, which fixes many security issues. Many of these had previously been patched in the vendored libxml 2.9.2 in the 1.6.7.x branch, but some are newer.

See these libxml2 email posts for more:

* https://mail.gnome.org/archives/xml/2015-November/msg00012.html
* https://mail.gnome.org/archives/xml/2016-May/msg00023.html

For a more detailed analysis, you may care to read Canonical's take on these security issues:

* http://www.ubuntu.com/usn/usn-2994-1


[MRI] Bundled libxslt is upgraded to 1.1.29, which fixes a security issue as well as many long-known outstanding bugs, some features, some portability improvements, and general cleanup.

See this libxslt email post for more:

* https://mail.gnome.org/archives/xslt/2016-May/msg00004.html


## Features

Several changes were made to improve performance:

* [MRI] Simplify NodeSet#to_a with a minor speed-up. (#1397)
* XML::Node#ancestors optimization. (#1297) (Thanks, Bruno Sutic!)
* Use Symbol#to_proc where we weren't previously. (#1296) (Thanks, Bruno Sutic!)
* XML::DTD#each uses implicit block calls. (Thanks, @glaucocustodio!)
* Fall back to the `pkg-config` gem if we're having trouble finding the system libxml2. This should help many FreeBSD users. (#1417)
* Set document encoding appropriately even on blank document. (#1043) (Thanks, @batter!)


## Bug Fixes

* [JRuby] fix slow add_child (#692)
* [JRuby] fix load errors when deploying to JRuby/Torquebox (#1114) (Thanks, @atambo and @jvshahid!)
* [JRuby] fix NPE when inspecting nodes returned by NodeSet#drop (#1042) (Thanks, @mkristian!)
* [JRuby] fix nil attriubte node's namespace in reader (#1327) (Thanks, @codekitchen!)
* [JRuby] fix Nokogiri munging unicode characters that require more than 2 bytes (#1113) (Thanks, @mkristian!)
* [JRuby] allow unlinking an unparented node (#1112, #1152) (Thanks, @esse!)
* [JRuby] allow Fragment parsing on a frozen string (#444, #1077)
* [JRuby] HTML `style` tags are no longer encoded (#1316) (Thanks, @tbeauvais!)
* [MRI] fix assertion failure while accessing attribute node's namespace in reader (#843) (Thanks, @2potatocakes!)
* [MRI] fix issue with GCing namespace nodes returned in an xpath query. (#1155)
* [MRI] Ensure C strings are null-terminated. (#1381)
* [MRI] Ensure Rubygems is loaded before using mini_portile2 at installation. (#1393, #1411) (Thanks, @JonRowe!)
* [MRI] Handling another edge case where the `libxml-ruby` gem's global callbacks were smashing the heap. (#1426). (Thanks to @bbergstrom for providing an isolated test case!)
* [MRI] Ensure encodings are passed to Sax::Parser xmldecl callback. (#844)
* [MRI] Ensure default ns prefix is applied correctly when reparenting nodes to another document. (#391) (Thanks, @ylecuyer!)
* [MRI] Ensure Reader handles non-existent attributes as expected. (#1254) (Thanks, @ccutrer!)
* [MRI] Cleanup around namespace handling when reparenting nodes. (#1332, #1333, #1444) (Thanks, @cuttrer and @bradleybeddoes!)
* unescape special characters in CSS queries (#1303) (Thanks, @twalpole!)
* consistently handle empty documents (#1349)
* Update to mini_portile2 2.1.0 to address whitespace-handling during patching. (#1402)
* Fix encoding of xml node namespaces.
* Work around issue installing Nokogiri on overlayfs (commonly used in Docker containers). (#1370, #1405)



## Other Notes

* Removed legacy code remaining from Ruby 1.8.x support.
* Removed legacy code remaining from REE support.
* Removing hacky workarounds for bugs in some older versions of libxml2.
* Handling C strings in a forward-compatible manner, see https://github.com/ruby/ruby/blob/v2_2_0/NEWS#L319


# 1.6.7.2 / 2016-01-20

This version pulls in several upstream patches to the vendored libxml2 and libxslt to address:

  CVE-2015-7499

Ubuntu classifies this as "Priority: Low", RedHat classifies this as "Impact: Moderate", and NIST classifies this as "Severity: 5.0 (MEDIUM)".

MITRE record is https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2015-7499


# 1.6.7.1 / 2015-12-16

This version pulls in several upstream patches to the vendored libxml2 and libxslt to address:

  CVE-2015-5312
  CVE-2015-7497
  CVE-2015-7498
  CVE-2015-7499
  CVE-2015-7500
  CVE-2015-8241
  CVE-2015-8242
  CVE-2015-8317

See also http://www.ubuntu.com/usn/usn-2834-1/


# 1.6.7 / 2015-11-29

## Notes

This version supports native builds on Windows using the RubyInstaller
DevKit. It also supports Ruby 2.2.x on Windows, as well as making
several other improvements to the installation process on various
platforms.

This version also includes the security patches already applied in
v1.6.6.3 and v1.6.6.4 to the vendored libxml2 and libxslt source.
See #1374 and #1376 for details.

## Features

* Cross-built gems now have a proper ruby version requirement. (#1266)
* Ruby 2.2.x is supported on Windows.
* Native build is supported on Windows.
* [MRI] libxml2 and libxslt `config.guess` files brought up to date. (#1326) (Thanks, @hernan-erasmo!)
* [JRuby] fix error in validating files with jruby (#1355, #1361) (Thanks, @twalpole!)
* [MRI, OSX] Patch to handle nonstandard location of `iconv.h`. (#1206, #1210, #1218, #1345) (Thanks, @neonichu!)

## Bug Fixes

* [JRuby] reset the namespace cache when replacing the document's innerHtml (#1265) (Thanks, @mkristian!)
* [JRuby] Document#parse should support IO objects that respond to #read. (#1124) (Thanks, Jake Byman!)
* [MRI] Duplicate-id errors when setting the `id` attribute on HTML documents are now silenced. (#1262)
* [JRuby] SAX parser cuts texts in pieces when square brackets exist. (#1261)
* [JRuby] Namespaced attributes aren't removed by remove_attribute. (#1299)


# 1.6.6.4 / 2015-11-19

This version pulls in an upstream patch to the vendored libxml2 to address:

* unclosed comment uninitialized access issue (#1376)

This issue was assigned CVE-2015-8710 after the fact. See http://seclists.org/oss-sec/2015/q4/616 for details.


# 1.6.6.3 / 2015-11-16

This version pulls in several upstream patches to the vendored libxml2 and libxslt to address:

* CVE-2015-1819
* CVE-2015-7941_1
* CVE-2015-7941_2
* CVE-2015-7942
* CVE-2015-7942-2
* CVE-2015-8035
* CVE-2015-7995

See #1374 for details.


# 1.6.6.2 / 2015-01-23

## Bug fixes

* Fixed installation issue affecting compiler arguments. (#1230)


# 1.6.6.1 / 2015-01-22

Note that 1.6.6.0 was not released.


## Features

* Unified Node and NodeSet implementations of #search, #xpath and #css.
* Added Node#lang and Node#lang=.
* bin/nokogiri passes the URI to parse() if an HTTP URL is given.
* bin/nokogiri now loads ~/.nokogirirc so user can define helper methods, etc.
* bin/nokogiri can be configured to use Pry instead of IRB by adding a couple of lines to ~/.nokogirirc. (#1198)
* bin/nokogiri can better handle urls from STDIN (aiding use of xargs). (#1065)
* JRuby 9K support.


## Bug fixes

* DocumentFragment#search now matches against root nodes. (#1205)
* (MRI) More fixes related to handling libxml2 parse errors during DocumentFragment#dup. (#1196)
* (JRuby) Builder now handles namespace hrefs properly when there is a default ns. (#1039)
* (JRuby) Clear the XPath cache on attr removal. (#1109)
* `XML::Comment.new` argument types are now consistent and safe (and documented) across MRI and JRuby. (#1224)
* (MRI) Restoring support for Ruby 1.9.2 that was broken in v1.6.4.1 and v1.6.5. (#1207)
* Check if `zlib` is available before building `libxml2`. (#1188)
* (JRuby) HtmlSaxPushParser now exists. (#1147) (Thanks, Piotr Szmielew!)


# 1.6.5 / 2014-11-26

## Features

* Implement Slop#respond_to_missing?. (#1176)
* Optimized the XPath query generated by an `an+b` CSS query.


## Bug fixes

* Capture non-parse errors from Document#dup in Document#errors. (#1196)
* (JRuby) Document#canonicalize parameters are now consistent with MRI. (#1189)


# 1.6.4.1 / 2014-11-05

## Bug fixes

* (MRI) Fix a bug where CFLAGS passed in are dropped. (#1188)
* Fix a bug where CSS selector :nth(n) did not work. (#1187)


# 1.6.4 / 2014-11-04

## Features

* (MRI) Bundled Libxml2 is upgraded to 2.9.2.
* (MRI) `nokogiri --version` will include a list of applied patches.
* (MRI) Nokogiri no longer prints messages directly to TTY while building the extension.
* (MRI) Detect and help user fix a missing /usr/include/iconv.h on OS X. (#1111)
* (MRI) Improve the iconv detection for building libxml2.

## Bug fixes

* (MRI) Fix DocumentFragment#element_children (#1138).
* Fix a bug with CSS attribute selector without any prefix where "foo [bar]" was treated as "foo[bar]". (#1174)


# 1.6.3.1 / 2014-07-21

## Bug fixes

* Addressing an Apple Macintosh installation problem for GCC users. #1130 (Thanks, @zenspider!)


# 1.6.3 / 2014-07-20

## Features

* Added Node#document? and Node#processing_instruction?


## Bug fixes

* [JRuby] Fix Ruby memory exhaustion vulnerability. #1087 (Thanks, @ocher)
* [MRI] Fix segfault during GC when using `libxml-ruby` and `nokogiri` together in multi-threaded environment. #895 (Thanks, @ender672!)
* Building on OSX 10.9 stock ruby 2.0.0 now works. #1101 (Thanks, @zenspider!)
* Node#parse now works again for HTML document nodes (broken in 1.6.2+).
* Processing instructions can now be added via Node#add_next_sibling.


# 1.6.2.1 / 2014-05-13

## Bug fixes

* Fix statically-linked libxml2 installation when using universal builds of Ruby. #1104
* Patching `mini_portile` to address the git dependency detailed in #1102.
* Library load fix to address segfault reported on some systems. #1097


# 1.6.2 / 2014-05-12

## Security Note

A set of security and bugfix patches have been backported from the libxml2 and libxslt repositories onto the version of 2.8.0 packaged with Nokogiri, including these notable security fixes:

* https://git.gnome.org/browse/libxml2/commit/?id=4629ee02ac649c27f9c0cf98ba017c6b5526070f
* CVE-2013-2877 https://git.gnome.org/browse/libxml2/commit/?id=e50ba8164eee06461c73cd8abb9b46aa0be81869
* CVE-2014-0191 https://git.gnome.org/browse/libxml2/commit/?id=9cd1c3cfbd32655d60572c0a413e017260c854df

It is recommended that you upgrade from 1.6.x to this version as soon as possible.

## Compatibility Note

Now requires libxml >= 2.6.21 (was previously >= 2.6.17).

## Features

* Add cross building of fat binary gems for 64-Bit Windows (x64-mingw32) and add support for native builds on Windows. #864, #989, #1072
* (MRI) Alias CP932 to Windows-31J if iconv does not support Windows-31J.
* (MRI) Nokogiri now links packaged libraries statically. To disable static linking, pass --disable-static to extconf.rb. #923
* (MRI) Fix a library path (LIBPATH) precedence problem caused by CRuby bug #9760.
* (MRI) Nokogiri automatically deletes directories of packaged libraries only used during build. To keep them for debugging purposes, pass --disable-clean to extconf.rb. #952
* (MRI) Nokogiri now builds libxml2 properly with iconv support on platforms where libiconv is installed outside the system default directories, such as FreeBSD.
* Add support for an-b in nth selectors. #886 (Thanks, Magnus Bergmark!)
* Add support for bare and multiple :not() functions in selectors. #887 (Thanks, Magnus Bergmark!)
* (MRI) Add an extconf.rb option --use-system-libraries, alternative to setting the environment variable NOKOGIRI_USE_SYSTEM_LIBRARIES.
* (MRI) Update packaged libraries: libxslt to 1.1.28, zlib to 1.2.8, and libiconv to 1.14, respectively.
* Nokogiri::HTML::Document#title= and #meta_encoding= now always add an element if not present, trying hard to find the best place to put it.
* Nokogiri::XML::DTD#html_dtd? and #html5_dtd? are added.
* Nokogiri::XML::Node#prepend_child is added. #664
* Nokogiri::XML::SAX::ParserContext#recovery is added. #453
* Fix documentation for XML::Node#namespace. #803 #802 (Thanks, Hoylen Sue)
* Allow Nokogiri::XML::Node#parse from unparented non-element nodes. #407

## Bugfixes

* Ensure :only-child pseudo class works within :not pseudo class. #858 (Thanks, Yamagishi Kazutoshi!)
* Don't call pkg_config when using bundled libraries in extconf.rb #931 (Thanks, Shota Fukumori!)
* Nokogiri.parse() does not mistake a non-HTML document like a RSS document as HTML document. #932 (Thanks, Yamagishi Kazutoshi!)
* (MRI) Perform a node type check before adding a child node to another. Previously adding a text node to another as a child could cause a SEGV. #1092
* (JRuby) XSD validation crashes in Java version. #373
* (JRuby) Document already has a root node error while using Builder. #646
* (JRuby) c14n tests are all passing on JRuby. #226
* Parsing empty documents raise SyntaxError in strict mode. #1005
* (JRuby) Make xpath faster by caching the xpath context. #741
* (JRuby) XML SAX push parser leaks memory on JRuby, but not on MRI. #998
* (JRuby) Inconsistent behavior aliasing the default namespace. #940
* (JRuby) Inconsistent behavior between parsing and adding namespaces. #943
* (JRuby) Xpath returns inconsistent result set on cloned document with namespaces and attributes. #1034
* (JRuby) Java-Implementation forgets element namespaces #902
* (JRuby) JRuby-Nokogiri does not recognise attributes inside namespaces #1081
* (JRuby) JRuby-Nokogiri has different comment node name #1080
* (JRuby) JAXPExtensionsProvider / Java 7 / Secure Processing #1070

# 1.6.1 / 2013-12-14

* Bugfixes

  * (JRuby) Fix out of memory bug when certain invalid documents are parsed.
  * (JRuby) Fix regression of billion-laughs vulnerability. #586


# 1.6.0 / 2013-06-08

This release was based on v1.5.10 and 1.6.0.rc1, and contains changes
mentioned in both.

* Deprecations

  * Remove pre 1.9 monitoring from Travis.


# 1.6.0.rc1 / 2013-04-14

This release was based on v1.5.9, and so does not contain any fixes
mentioned in the notes for v1.5.10.

* Notes

  * mini_portile is now a runtime dependency
  * Ruby 1.9.2 and higher now required


* Features

  * (MRI) Source code for libxml 2.8.0 and libxslt 1.2.26 is packaged
    with the gem. These libraries are compiled at gem install time
    unless the environment variable NOKOGIRI_USE_SYSTEM_LIBRARIES is
    set. VERSION_INFO (also `nokogiri -v`) exposes whether libxml was
    compiled from packaged source, or the system library was used.
  * (Windows) libxml upgraded to 2.8.0


* Deprecations

  * Support for Ruby 1.8.7 and prior has been dropped


# 1.5.11 / 2013-12-14

* Bugfixes

  * (JRuby) Fix out of memory bug when certain invalid documents are parsed.
  * (JRuby) Fix regression of billion-laughs vulnerability. #586


# 1.5.10 / 2013-06-07

* Bugfixes

  * (JRuby) Fix "null document" error when parsing an empty IO in jruby 1.7.3. #883
  * (JRuby) Fix schema validation when XSD has DOCTYPE set to DTD. #912 (Thanks, Patrick Cheng!)
  * (MRI) Fix segfault when there is no default subelement for an HTML node. #917


* Notes

  * Use rb_ary_entry instead of RARRAY_PTR (you know, for Rubinius). #877 (Thanks, Dirkjan Bussink!)
  * Fix TypeError when running tests. #900 (Thanks, Cédric Boutillier!)


# 1.5.9 / 2013-03-21

* Bugfixes

  * Ensure that prefixed attributes are properly namespaced when reparented. #869
  * Fix for inconsistent namespaced attribute access for SVG nested in HTML. #861
  * (MRI) Fixed a memory leak in fragment parsing if nodes are not all subsequently reparented. #856


# 1.5.8 / 2013-03-19

* Bugfixes

  * (JRuby) Fix EmptyStackException thrown by elements with xlink:href attributes and no base_uri #534, #805. (Thanks, Patrick Quinn and Brian Hoffman!)
  * Fixes duplicate attributes issue introduced in 1.5.7. #865
  * Allow use of a prefixed namespace on a root node using Nokogiri::XML::Builder #868


# 1.5.7 / 2013-03-18

* Features

  * Windows support for Ruby 2.0.


* Bugfixes

  * SAX::Parser.parse_io throw an error when used with lower case encoding. #828
  * (JRuby) Java Nokogiri is finally green (passes all tests) under 1.8 and 1.9 mode. High five everyone. #798, #705
  * (JRuby) Nokogiri::XML::Reader broken (as a pull parser) on jruby - reads the whole XML document. #831
  * (JRuby) JRuby hangs parsing "&amp;". #837
  * (JRuby) JRuby NPE parsing an invalid XML instruction. #838
  * (JRuby) Node#content= incompatibility. #839
  * (JRuby) to_xhtml doesn't print the last slash for self-closing tags in JRuby. #834
  * (JRuby) Adding an EntityReference after a Text node mangles the entity in JRuby. #835
  * (JRuby) JRuby version inconsistency: nil for empty attributes. #818
  * CSS queries for classes (e.g., ".foo") now treat all whitespace identically. #854
  * Namespace behavior cleaned up and made consistent between JRuby and MRI. #846, #801 (Thanks, Michael Klein!)
  * (MRI) SAX parser handles empty processing instructions. #845


# 1.5.6 / 2012-12-19

* Features

  * Improved performance of XML::Document#collect_namespaces. #761 (Thanks, Juergen Mangler!)
  * New callback SAX::Document#processing_instruction (Thanks, Kitaiti Makoto!)
  * Node#native_content= allows setting unescaped node contant. #768
  * XPath lookup with namespaces supports symbol keys. #729 (Thanks, Ben Langfeld.)
  * XML::Node#[]= stringifies values. #729 (Thanks, Ben Langfeld.)
  * bin/nokogiri will process a document from $stdin
  * bin/nokogiri -e will execute a program from the command line
  * (JRuby) bin/nokogiri --version will print the Xerces and NekoHTML versions.


* Bugfixes

  * Nokogiri now detects XSLT transform errors. #731 (Thanks, Justin Fitzsimmons!)
  * Don't throw an Error when trying to replace top-level text node in DocumentFragment. #775
  * Raise an ArgumentError if an invalid encoding is passed to the SAX parser. #756 (Thanks, Bradley Schaefer!)
  * Prefixed element inconsistency between CRuby and JRuby. #712
  * (JRuby) space prior to xml preamble causes nokogiri to fail parsing. (fixed along with #748) #790
  * (JRuby) Fixed the bug Nokogiri::XML::Node#content inconsistency between Java and C. #794, #797
  * (JRuby) raises INVALID_CHARACTER_ERR exception when EntityReference name starts with '#'. #719
  * (JRuby) doesn't coerce namespaces out of strings on a direct subclass of Node. #715
  * (JRuby) Node#content now renders newlines properly. #737 (Thanks, Piotr Szmielew!)
  * (JRuby) Unknown namespace are ignore when the recover option is used. #748
  * (JRuby) XPath queries for namespaces should not throw exceptions when called twice in a row. #764
  * (JRuby) More consistent (with libxml2) whitespace formatting when emitting XML. #771
  * (JRuby) namespaced attributes broken when appending raw xml to builder. #770
  * (JRuby) Nokogiri::XML::Document#wrap raises undefined method `length' for nil:NilClass when trying to << to a node. #781
  * (JRuby) Fixed "bad file descriptor" bug when closing open file descriptors. #495
  * (JRuby) JRuby/CRuby incompatibility for attribute decorators. #785
  * (JRuby) Issues parsing valid XML with no internal subset in the DTD. #547, #811
  * (JRuby) Issues parsing valid node content when it contains colons. #728
  * (JRuby) Correctly parse the doc type of html documents. #733
  * (JRuby) Include dtd in the xml output when a builder is used with create_internal_subset. #751
  * (JRuby) builder requires textwrappers for valid utf8 in jruby, not in mri. #784


# 1.5.5 / 2012-06-24

* Features

  * Much-improved support for JRuby in 1.9 mode! Yay!

* Bugfixes

  * Regression in JRuby Nokogiri add_previous_sibling (1.5.0 -> 1.5.1) #691 (Thanks, John Shahid!)
  * JRuby unable to create HTML doc if URL arg provided #674 (Thanks, John Shahid!)
  * JRuby raises NullPointerException when given HTML document is nil or empty string. #699
  * JRuby 1.9 error, uncaught throw 'encoding_found', has been fixed. #673
  * Invalid encoding returned in JRuby with US-ASCII. #583
  * XmlSaxPushParser raises IndexOutOfBoundsException when over 512 characters are given. #567, #615
  * When xpath evaluation returns empty NodeSet, decorating NodeSet's base document raises exception. #514
  * JRuby raises exception when xpath with namespace is specified. pull request #681 (Thanks, Piotr Szmielew)
  * JRuby renders nodes without their namespace when subclassing Node. #695
  * JRuby raises NAMESPACE_ERR (org.w3c.dom.DOMException) while instantiating RDF::RDFXML::Writer. #683
  * JRuby is not able to use namespaces in xpath. #493
  * JRuby's Entity resolving should be consistent with C-Nokogiri #704, #647, #703


# 1.5.4 / 2012-06-12

* Features

  * The "nokogiri" script now has more verbose output when passed the `--rng` option. #675 (Thanks, Dan Radez!)
  * Build support on hardened Debian systems that use `-Werror=format-security`. #680.
  * Better build support for systems with pkg-config. #584
  * Better build support for systems with multiple iconv installations.

* Bugfixes

  * Segmentation fault when creating a comment node for a DocumentFragment. #677, #678.
  * Treat '.' as xpath in at() and search(). #690

  * (MRI, Security) Default parse options for XML documents were
    changed to not make network connections during document parsing,
    to avoid XXE vulnerability. #693

    To re-enable this behavior, the configuration method `nononet` may
    be called, like this:

    Nokogiri::XML::Document.parse(xml) { |config| config.nononet }

    Insert your own joke about double-negatives here.


# 1.5.3 / 2012-06-01

* Features

  * Support for "prefixless" CSS selectors ~, > and + like jQuery
    supports. #621, #623. (Thanks, David Lee!)
  * Attempting to improve installation on homebrew 0.9 (with regards
    to iconv). Isn't package management convenient?

* Bugfixes

  * Custom xpath functions with empty nodeset arguments cause a
    segfault. #634.
  * Nokogiri::XML::Node#css now works for XML documents with default
    namespaces when the rule contains attribute selector without
    namespace.
  * Fixed marshalling bugs around how arguments are passed to (and
    returned from) XSLT custom xpath functions. #640.
  * Nokogiri::XML::Reader#outer_xml is broken in JRuby #617
  * Nokogiri::XML::Attribute on JRuby returns a nil namespace #647
  * Nokogiri::XML::Node#namespace= cannot set a namespace without a
    prefix on JRuby #648
  * (JRuby) 1.9 mode causes dead lock while running rake #571
  * HTML::Document#meta_encoding does not raise exception on docs with
    malformed content-type. #655
  * Fixing segfault related to unsupported encodings in in-context
    parsing on 1.8.7. #643
  * (JRuby) Concurrency issue in XPath parsing. #682


# 1.5.2 / 2012-03-09

Repackaging of 1.5.1 with a gemspec that is compatible with older Rubies. #631, #632.


# 1.5.1 / 2012-03-09

* Features

  * XML::Builder#comment allows creation of comment nodes.
  * CSS searches now support namespaced attributes. #593
  * Java integration feature is added. Now, XML::Document.wrap
    and XML::Document#to_java methods are available.
  * RelaxNG validator support in the `nokogiri` cli utility. #591 (thanks, Dan Radez!)

* Bugfixes

  * Fix many memory leaks and segfault opportunities. Thanks, Tim Elliott!
  * extconf searches homebrew paths if homebrew is installed.
  * Inconsistent behavior of Nokogiri 1.5.0 Java #620
  * Inheriting from Nokogiri::XML::Node on JRuby (1.6.4/5) fails #560
  * XML::Attr nodes are not allowed to be added as node children, so an
    exception is raised. #558
  * No longer defensively "pickle" adjacent text nodes on
    Node#add_next_sibling and Node#add_previous_sibling calls. #595.
  * Java version inconsistency: it returns nil for empty attributes #589
  * to_xhtml incorrectly generates <p /></p> when tag is empty #557
  * Document#add_child now accepts a Node, NodeSet, DocumentFragment,
    or String. #546.
  * Document#create_element now recognizes namespaces containing
    non-word characters (like "SOAP-ENV"). This is mostly relevant to
    users of Builder, which calls Document#create_element for nearly
    everything. #531.
  * File encoding broken in 1.5.0 / jruby / windows #529
  * Java version does not return namespace defs as attrs for ::HTML #542
  * Bad file descriptor with Nokogiri 1.5.0 #495
  * remove_namespace! doesn't work in pure java version #492
  * The Nokogiri Java native build throws a null pointer exception
    when ActiveSupport's .blank? method is called directly on a parsed
    object. #489
  * 1.5.0 Not using correct character encoding #488
  * Raw XML string in XML Builder broken on JRuby #486
  * Nokogiri 1.5.0 XML generation broken on JRuby #484
  * Do not allow multiple root nodes. #550
  * Fixes for custom XPath functions. #605, #606 (thanks, Juan Wajnerman!)
  * Node#to_xml does not override :save_with if it is provided. #505
  * Node#set is a private method (JRuby). #564 (thanks, Nick Sieger!)
  * C14n cleanup and Node#canonicalize (thanks, Ivan Pirlik!) #563


# 1.5.0 / 2011-07-01

* Notes

  * See changelog from 1.4.7

* Features

  * extracted sets of Node::SaveOptions into Node::SaveOptions::DEFAULT_{X,H,XH}TML (refactor)

* Bugfixes

  * default output of XML on JRuby is no longer formatted due to
    inconsistent whitespace handling. #415
  * (JRuby) making empty NodeSets with null `nodes` member safe to operate on. #443
  * Fix a bug in advanced encoding detection that leads to partially
    duplicated document when parsing an HTML file with unknown
    encoding.
  * Add support for <meta charset="...">.


# 1.5.0 beta3 / 2010/12/02

* Notes

  * JRuby performance tuning
  * See changelog from 1.4.4

* Bugfixes

  * Node#inner_text no longer returns nil. (JRuby) #264


# 1.5.0 beta2 / 2010/07/30

* Notes

  * See changelog from 1.4.3


# 1.5.0 beta1 / 2010/05/22

* Notes

  * JRuby support is provided by a new pure-java backend.

* Deprecations

  * Ruby 1.8.6 is deprecated. Nokogiri will install, but official support is ended.
  * LibXML 2.6.16 and earlier are deprecated. Nokogiri will refuse to install.
  * FFI support is removed.


# 1.4.7 / 2011-07-01

* Bugfixes

  * Fix a bug in advanced encoding detection that leads to partially
    duplicated document when parsing an HTML file with unknown
    encoding. Thanks, Timothy Elliott (@ender672)! #478


# 1.4.6 / 2011-06-19

* Notes

  * This version is functionally identical to 1.4.5.
  * Ruby 1.8.6 support has been restored.


# 1.4.5 / 2011-05-19

* New Features

  * Nokogiri::HTML::Document#title accessor gets and sets the document title.
  * extracted sets of Node::SaveOptions into Node::SaveOptions::DEFAULT_{X,H,XH}TML (refactor)
  * Raise an exception if a string is passed to Nokogiri::XML::Schema#validate. #406

* Bugfixes

  * Node#serialize-and-friends now accepts a SaveOption object as the, erm, save object.
  * Nokogiri::CSS::Parser has-a Nokogiri::CSS::Tokenizer
  * (JRUBY+FFI only) Weak references are now threadsafe. #355
  * Make direct start_element() callback (currently used for
    HTML::SAX::Parser) pass attributes in assoc array, just as
    emulated start_element() callback does.  rel. #356
  * HTML::SAX::Parser should call back a block given to parse*() if any, just as XML::SAX::Parser does.
  * Add further encoding detection to HTML parser that libxml2 does not do.
  * Document#remove_namespaces! now handles attributes with namespaces. #396
  * XSLT::Stylesheet#transform no longer segfaults when handed a non-XML::Document. #452
  * XML::Reader no longer segfaults when under GC pressure. #439


# 1.4.4 / 2010-11-15

* New Features

  * XML::Node#children= sets the node's inner html (much like #inner_html=), but returns the reparent node(s).
  * XSLT supports function extensions. #336
  * XPath bind parameter substitution. #329
  * XML::Reader node type constants. #369
  * SAX Parser context provides line and column information

* Bugfixes

  * XML::DTD#attributes returns an empty hash instead of nil when there are no attributes.
  * XML::DTD#{keys,each} now work as expected. #324
  * {XML,HTML}::DocumentFragment.{new,parse} no longer strip leading and trailing whitespace. #319
  * XML::Node#{add_child,add_previous_sibling,add_next_sibling,replace} return a NodeSet when passed a string.
  * Unclosed tags parsed more robustly in fragments. #315
  * XML::Node#{replace,add_previous_sibling,add_next_sibling} edge cases fixed related to libxml's text node merging. #308
  * Fixed a segfault when GC occurs during xpath handler argument marshalling. #345
  * Added hack to Slop decorator to work with previously defined methods. #330
  * Fix a memory leak when duplicating child nodes. #353
  * Fixed off-by-one bug with nth-last-{child,of-type} CSS selectors when NOT using an+b notation. #354
  * Fixed passing of non-namespace attributes to SAX::Document#start_element. #356
  * Workaround for libxml2 in-context parsing bug. #362
  * Fixed NodeSet#wrap on nodes within a fragment. #331


# 1.4.3 / 2010/07/28

* New Features

  * XML::Reader#empty_element? returns true for empty elements. #262
  * Node#remove_namespaces! now removes namespace *declarations* as well. #294
  * NodeSet#at_xpath, NodeSet#at_css and NodeSet#> do what the corresponding
    methods of Node do.

* Bugfixes

  * XML::NodeSet#{include?,delete,push} accept an XML::Namespace
  * XML::Document#parse added for parsing in the context of a document
  * XML::DocumentFragment#inner_html= works with contextual parsing! #298, #281
  * lib/nokogiri/css/parser.y Combined CSS functions + pseudo selectors fixed
  * Reparenting text nodes is safe, even when the operation frees adjacent merged nodes. #283
  * Fixed libxml2 versionitis issue with xmlFirstElementChild et al. #303
  * XML::Attr#add_namespace now works as expected. #252
  * HTML::DocumentFragment uses the string's encoding. #305
  * Fix the CSS3 selector translation rule for the general sibling combinator
    (a.k.a. preceding selector) that incorrectly converted "E ~ F G" to
    "//F//G[preceding-sibling::E]".


# 1.4.2 / 2010/05/22

* New Features

  * XML::Node#parse will parse XML or HTML fragments with respect to the
    context node.
  * XML::Node#namespaces returns all namespaces defined in the node and all
    ancestor nodes
    (previously did not return ancestors' namespace definitions).
  * Added Enumerable to XML::Node
  * Nokogiri::XML::Schema#validate now uses xmlSchemaValidateFile if a
    filename is passed, which is faster and more memory-efficient. GH #219
  * XML::Document#create_entity will create new EntityDecl objects. GH #174
  * JRuby FFI implementation no longer uses ObjectSpace._id2ref,
    instead using Charles Nutter's rocking Weakling gem.
  * Nokogiri::XML::Node#first_element_child fetch the first child node that is
    an ELEMENT node.
  * Nokogiri::XML::Node#last_element_child fetch the last child node that is
    an ELEMENT node.
  * Nokogiri::XML::Node#elements fetch all children nodes that are ELEMENT
    nodes.
  * Nokogiri::XML::Node#add_child, #add_previous_sibling, #before,
    #add_next_sibling, #after, #inner_html, #swap and #replace all now
    accept a Node, DocumentFragment, NodeSet, or a string containing
    markup.
  * Node#fragment? indicates whether a node is a DocumentFragment.

* Bugfixes

  * XML::NodeSet is now always decorated (if the document has decorators).
    GH #198
  * XML::NodeSet#slice gracefully handles offset+length larger than the set
    length. GH #200
  * XML::Node#content= safely unlinks previous content. GH #203
  * XML::Node#namespace= takes nil as a parameter
  * XML::Node#xpath returns things other than NodeSet objects. GH #208
  * XSLT::StyleSheet#transform accepts hashes for parameters. GH #223
  * Psuedo selectors inside not() work. GH #205
  * XML::Builder doesn't break when nodes are unlinked.
    Thanks to vihai! GH #228
  * Encoding can be forced on the SAX parser. Thanks Eugene Pimenov! GH #204
  * XML::DocumentFragment uses XML::Node#parse to determine children.
  * Fixed a memory leak in xml reader. Thanks sdor! GH #244
  * Node#replace returns the new child node as claimed in the
    RDoc. Previously returned +self+.

* Notes

  * The Windows gems now bundle DLLs for libxml 2.7.6 and libxslt
    1.1.26. Prior to this release, libxml 2.7.3 and libxslt 1.1.24
    were bundled.


# 1.4.1 / 2009/12/10

* New Features

  * Added Nokogiri::LIBXML_ICONV_ENABLED
  * Alias Node#[] to Node#attr
  * XML::Node#next_element added
  * XML::Node#> added for searching a nodes immediate children
  * XML::NodeSet#reverse added
  * Added fragment support to Node#add_child, Node#add_next_sibling,
    Node#add_previous_sibling, and Node#replace.
  * XML::Node#previous_element implemented
  * Rubinius support
  * Ths CSS selector engine now supports :has()
  * XML::NodeSet#filter() was added
  * XML::Node.next= and .previous= are aliases for add_next_sibling and add_previous_sibling. GH #183

* Bugfixes

  * XML fragments with namespaces do not raise an exception (regression in 1.4.0)
  * Node#matches? works in nodes contained by a DocumentFragment. GH #158
  * Document should not define add_namespace() method. GH #169
  * XPath queries returning namespace declarations do not segfault.
  * Node#replace works with nodes from different documents. GH #162
  * Adding XML::Document#collect_namespaces
  * Fixed bugs in the SOAP4R adapter
  * Fixed bug in XML::Node#next_element for certain edge cases
  * Fixed load path issue with JRuby under Windows. GH #160.
  * XSLT#apply_to will honor the "output method". Thanks richardlehane!
  * Fragments containing leading text nodes with newlines now parse properly. GH #178.


# 1.4.0 / 2009/10/30

* Happy Birthday!

* New Features

  * Node#at_xpath returns the first element of the NodeSet matching the XPath
    expression.
  * Node#at_css returns the first element of the NodeSet matching the CSS
    selector.
  * NodeSet#| for unions GH #119 (Thanks Serabe!)
  * NodeSet#inspect makes prettier output
  * Node#inspect implemented for more rubyish document inspecting
  * Added XML::DTD#external_id
  * Added XML::DTD#system_id
  * Added XML::ElementContent for DTD Element content validity
  * Better namespace declaration support in Nokogiri::XML::Builder
  * Added XML::Node#external_subset
  * Added XML::Node#create_external_subset
  * Added XML::Node#create_internal_subset
  * XML Builder can append raw strings (GH #141, patch from dudleyf)
  * XML::SAX::ParserContext added
  * XML::Document#remove_namespaces! for the namespace-impaired

* Bugfixes

  * returns nil when HTML documents do not declare a meta encoding tag. GH #115
  * Uses RbConfig::CONFIG['host_os'] to adjust ENV['PATH'] GH #113
  * NodeSet#search is more efficient GH #119 (Thanks Serabe!)
  * NodeSet#xpath handles custom xpath functions
  * Fixing a SEGV when XML::Reader gets attributes for current node
  * Node#inner_html takes the same arguments as Node#to_html GH #117
  * DocumentFragment#css delegates to it's child nodes GH #123
  * NodeSet#[] works with slices larger than NodeSet#length GH #131
  * Reparented nodes maintain their namespace. GH #134
  * Fixed SEGV when adding an XML::Document to NodeSet
  * XML::SyntaxError can be duplicated. GH #148

* Deprecations

  * Hpricot compatibility layer removed


# 1.3.3 / 2009/07/26

* New Features

  * NodeSet#children returns all children of all nodes

* Bugfixes

  * Override libxml-ruby's global error handler
  * ParseOption#strict fixed
  * Fixed a segfault when sending an empty string to Node#inner_html= GH #88
  * String encoding is now set to UTF-8 in Ruby 1.9
  * Fixed a segfault when moving root nodes between documents. GH #91
  * Fixed an O(n) penalty on node creation. GH #101
  * Allowing XML documents to be output as HTML documents

* Deprecations

  * Hpricot compatibility layer will be removed in 1.4.0


# 1.3.2 / 2009-06-22

* New Features

  * Nokogiri::XML::DTD#validate will validate your document

* Bugfixes

  * Nokogiri::XML::NodeSet#search will search top level nodes. GH #73
  * Removed namespace related methods from Nokogiri::XML::Document
  * Fixed a segfault when a namespace was added twice
  * Made nokogiri work with Snow Leopard GH #79
  * Mailing list has moved to: http://groups.google.com/group/nokogiri-talk
  * HTML fragments now correctly handle comments and CDATA blocks. GH #78
  * Nokogiri::XML::Document#clone is now an alias of dup

* Deprecations

  * Nokogiri::XML::SAX::Document#start_element_ns is deprecated, please switch
    to Nokogiri::XML::SAX::Document#start_element_namespace
  * Nokogiri::XML::SAX::Document#end_element_ns is deprecated, please switch
    to Nokogiri::XML::SAX::Document#end_element_namespace


# 1.3.1 / 2009-06-07

* Bugfixes

  * extconf.rb checks for optional RelaxNG and Schema functions
  * Namespace nodes are added to the Document node cache


# 1.3.0 / 2009-05-30

* New Features

  * Builder changes scope based on block arity
  * Builder supports methods ending in underscore similar to tagz
  * Nokogiri::XML::Node#<=> compares nodes based on Document position
  * Nokogiri::XML::Node#matches? returns true if Node can be found with
    given selector.
  * Nokogiri::XML::Node#ancestors now returns an Nokogiri::XML::NodeSet
  * Nokogiri::XML::Node#ancestors will match parents against optional selector
  * Nokogiri::HTML::Document#meta_encoding for getting the meta encoding
  * Nokogiri::HTML::Document#meta_encoding= for setting the meta encoding
  * Nokogiri::XML::Document#encoding= to set the document encoding
  * Nokogiri::XML::Schema for validating documents against XSD schema
  * Nokogiri::XML::RelaxNG for validating documents against RelaxNG schema
  * Nokogiri::HTML::ElementDescription for fetching HTML element descriptions
  * Nokogiri::XML::Node#description to fetch the node description
  * Nokogiri::XML::Node#accept implements Visitor pattern
  * bin/nokogiri for easily examining documents (Thanks Yutaka HARA!)
  * Nokogiri::XML::NodeSet now supports more Array and Enumerable operators:
    index, delete, slice, - (difference), + (concatenation), & (intersection),
    push, pop, shift, ==
  * Nokogiri.XML, Nokogiri.HTML take blocks that receive
    Nokogiri::XML::ParseOptions objects
  * Nokogiri::XML::Node#namespace returns a Nokogiri::XML::Namespace
  * Nokogiri::XML::Node#namespace= for setting a node's namespace
  * Nokogiri::XML::DocumentFragment and Nokogiri::HTML::DocumentFragment
    have a sensible API and a more robust implementation.
  * JRuby 1.3.0 support via FFI.

* Bugfixes

  * Fixed a problem with nil passed to CDATA constructor
  * Fragment method deals with regular expression characters
    (Thanks Joel!) LH #73
  * Fixing builder scope issues LH #61, LH #74, LH #70
  * Fixed a problem when adding a child could remove the child namespace LH#78
  * Fixed bug with unlinking a node then reparenting it. (GH#22)
  * Fixed failure to catch errors during XSLT parsing (GH#32)
  * Fixed a bug with attribute conditions in CSS selectors (GH#36)
  * Fixed intolerance of HTML attributes without values in Node#before/after/inner_html=. (GH#35)


# 1.2.3 / 2009-03-22

* Bugfixes

  * Fixing bug where a node is passed in to Node#new
  * Namespace should be assigned on DocumentFragment creation. LH #66
  * Nokogiri::XML::NodeSet#dup works GH #10
  * Nokogiri::HTML returns an empty Document when given a blank string GH#11
  * Adding a child will remove duplicate namespace declarations LH #67
  * Builder methods take a hash as a second argument


# 1.2.2 / 2009-03-14

* New features

  * Nokogiri may be used with soap4r. See XSD::XMLParser::Nokogiri
  * Nokogiri::XML::Node#inner_html= to set the inner html for a node
  * Nokogiri builder interface improvements
  * Nokogiri::XML::Node#swap swaps html for current node (LH #50)

* Bugfixes

  * Fixed a tag nesting problem in the Builder API (LH #41)
  * Nokogiri::HTML.fragment will properly handle text only nodes (LH #43)
  * Nokogiri::XML::Node#before will prepend text nodes (LH #44)
  * Nokogiri::XML::Node#after will append text nodes
  * Nokogiri::XML::Node#search automatically registers root namespaces (LH #42)
  * Nokogiri::XML::NodeSet#search automatically registers namespaces
  * Nokogiri::HTML::NamedCharacters delegates to libxml2
  * Nokogiri::XML::Node#[] can take a symbol (LH #48)
  * vasprintf for windows updated.  Thanks Geoffroy Couprie!
  * Nokogiri::XML::Node#[]= should not encode entities (LH #55)
  * Namespaces should be copied to reparented nodes (LH #56)
  * Nokogiri uses encoding set on the string for default in Ruby 1.9
  * Document#dup should create a new document of the same type (LH #59)
  * Document should not have a parent method (LH #64)


# 1.2.1 / 2009-02-23

* Bugfixes

  * Fixed a CSS selector space bug
  * Fixed Ruby 1.9 String Encoding (Thanks 角谷さん！)


# 1.2.0 / 2009-02-22

* New features

  * CSS search now supports CSS3 namespace queries
  * Namespaces on the root node are automatically registered
  * CSS queries use the default namespace
  * Nokogiri::XML::Document#encoding get encoding used for this document
  * Nokogiri::XML::Document#url get the document url
  * Nokogiri::XML::Node#add_namespace add a namespace to the node LH#38
  * Nokogiri::XML::Node#each iterate over attribute name, value pairs
  * Nokogiri::XML::Node#keys get all attribute names
  * Nokogiri::XML::Node#line get the line number for a node (Thanks Dirkjan Bussink!)
  * Nokogiri::XML::Node#serialize now takes an optional encoding parameter
  * Nokogiri::XML::Node#to_html, to_xml, and to_xhtml take an optional encoding
  * Nokogiri::XML::Node#to_str
  * Nokogiri::XML::Node#to_xhtml to produce XHTML documents
  * Nokogiri::XML::Node#values get all attribute values
  * Nokogiri::XML::Node#write_to writes the node to an IO object with optional encoding
  * Nokogiri::XML::ProcessingInstrunction.new
  * Nokogiri::XML::SAX::PushParser for all your push parsing needs.

* Bugfixes

  * Fixed Nokogiri::XML::Document#dup
  * Fixed header detection. Thanks rubikitch!
  * Fixed a problem where invalid CSS would cause the parser to hang

* Deprecations

  * Nokogiri::XML::Node.new_from_str will be deprecated in 1.3.0

* API Changes

  * Nokogiri::HTML.fragment now returns an XML::DocumentFragment (LH #32)


# 1.1.1

* New features

  * Added XML::Node#elem?
  * Added XML::Node#attribute_nodes
  * Added XML::Attr
  * XML::Node#delete added.
  * XML::NodeSet#inner_html added.

* Bugfixes

  * Not including an HTML entity for \r for HTML nodes.
  * Removed CSS::SelectorHandler and XML::XPathHandler
  * XML::Node#attributes returns an Attr node for the value.
  * XML::NodeSet implements to_xml


# 1.1.0

* New Features

  * Custom XPath functions are now supported.  See Nokogiri::XML::Node#xpath
  * Custom CSS pseudo classes are now supported.  See Nokogiri::XML::Node#css
  * Nokogiri::XML::Node#<< will add a child to the current node

* Bugfixes

  * Mutex lock on CSS cache access
  * Fixed build problems with GCC 3.3.5
  * XML::Node#to_xml now takes an indentation argument
  * XML::Node#dup takes an optional depth argument
  * XML::Node#add_previous_sibling returns new sibling node.


# 1.0.7

* Bugfixes

  * Fixed memory leak when using Dike
  * SAX parser now parses IO streams
  * Comment nodes have their own class
  * Nokogiri() should delegate to Nokogiri.parse()
  * Prepending rather than appending to ENV['PATH'] on windows
  * Fixed a bug in complex CSS negation selectors


# 1.0.6

* 5 Bugfixes

  * XPath Parser raises a SyntaxError on parse failure
  * CSS Parser raises a SyntaxError on parse failure
  * filter() and not() hpricot compatibility added
  * CSS searches via Node#search are now always relative
  * CSS to XPath conversion is now cached


# 1.0.5

* Bugfixes

  * Added mailing list and ticket tracking information to the README.txt
  * Sets ENV['PATH'] on windows if it doesn't exist
  * Caching results of NodeSet#[] on Document


# 1.0.4

* Bugfixes

  * Changed memory management from weak refs to document refs
  * Plugged some memory leaks
  * Builder blocks can call methods from surrounding contexts


# 1.0.3

* 5 Bugfixes

  * NodeSet now implements to_ary
  * XML::Document should not implement parent
  * More GC Bugs fixed.  (Mike is AWESOME!)
  * Removed RARRAY_LEN for 1.8.5 compatibility.  Thanks Shane Hanna.
  * inner_html fixed. (Thanks Yehuda!)


# 1.0.2

* 1 Bugfix

  * extconf.rb should not check for frex and racc


# 1.0.1

* 1 Bugfix

  * Made sure extconf.rb searched libdir and prefix so that ports libxml/ruby
    will link properly.  Thanks lucsky!


# 1.0.0 / 2008-07-13

* 1 major enhancement

  * Birthday!
