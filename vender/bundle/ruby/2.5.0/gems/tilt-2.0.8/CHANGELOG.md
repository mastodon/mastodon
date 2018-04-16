## master

## 2.0.8 (2017-07-24)

* Register .tsx for TypeScript (#315, backus)
* Use Haml 5's new API (#312, k0kubun)
* Use correct parser options for CommonMarker (#320, rewritten)
* Suppress warnings when no locals are used (#304, amatsuda)
* Haml: Accept `outvar` (#317, k0kubun)

## 2.0.7 (2017-03-19)

* Do not modify BasicObject during template compilation on ruby 2.0+ (#309, jeremyevans)

## 2.0.6 (2017-01-26)

* Add support for LiveScript (#286, @Announcement Jacob Francis Powers)
* Add support for Sigil (#302, winebarrel)
* Add support for Erubi (#308, jeremyevans)
* Add support for options in Liquid (#298, #299, laCour)
* Always sort locals by strings (#307, jeremyevans)

* Fix test warnings (#305, amatsuda)
* Fix indentation (#293, yui-knk)
* Use SVG badges in README (#294, vasinov)
* Fix typo and trailing space (#295, #296, karloescota)

## 2.0.5 (2016-06-02)

* Add support for reST using Pandoc (#284, mfenner)
* Make lazy loading thread-safe; remove warning (judofyr)

## 2.0.4 (2016-05-16)

* Fix regression in BuilderTemplate (#283, judofyr)

## 2.0.3 (2016-05-12)

* Add Pandoc support (#276, jmuheim)
* Add CommonMark support (#282, raphink)
* Add TypeScript support (#278, nghitran)
* Work with frozen string literal (#274, jeremyevans)
* Add MIME type for Babel (#273, SaitoWu)

## 2.0.2 (2016-01-06)

* Pass options to Redcarpet (#250, hughbien)
* Haml: Improve error message on frozen self (judofyr)
* Add basic support for Babel (judofyr)
* Add support for .litcoffee (#243, judofyr, mr-vinn)
* Document Tilt::Cache (#266, tommay)
* Sort local keys for better caching (#257, jeremyevans)
* Add more CSV options (#256, Juanmcuello)
* Add Prawn template (kematzy)
* Improve cache-miss performance in Tilt::Cache (#251, tommay)
* Add man page (#241, josephholsten)
* Support YAML/JSON data in bin/tilt (#241, josephholsten)

## 2.0.1 (2014-03-21)

* Fix Tilt::Mapping bug in Ruby 2.1.0 (9589652c569760298f2647f7a0f9ed4f85129f20)
* Fix `tilt --list` (#223, Achrome)
* Fix circular require (#221, amarshall)

## 2.0.0 (2013-11-30)

* Support Pathname in Template#new (#219, kabturek)
* Add Mapping#templates_for (judofyr)
* Support old-style #register (judofyr)
* Add Handlebars as external template engine (#204, judofyr, jimothyGator)
* Add org-ruby as external template engine (#207, judofyr, minad)
* Documentation typo (#208, elgalu)

## 2.0.0.beta1 (2013-07-16)

* Documentation typo (#202, chip)
* Use YARD for documentation (#189, judofyr)
* Add Slim as an external template engine (judofyr)
* Add Tilt.templates_for (#121, judofyr)
* Add Tilt.current_template (#151, judofyr)
* Avoid loading all files in tilt.rb (#160, #187, judofyr)
* Implement lazily required templates classes (#178, #187, judofyr)
* Move #allows_script and default_mime_type to metadata (#187, judofyr)
* Introduce Tilt::Mapping (#187, judofyr)
* Make template compilation thread-safe (#191, judofyr)

## 1.4.1 (2013-05-08)

* Support Arrays in pre/postambles (#193, jbwiv)

## 1.4.0 (2013-05-01)

* Better encoding support

## 1.3.7 (2013-04-09)

* Erubis: Check for the correct constant (#183, mattwildig)
* Don't fail when BasicObject is defined in 1.8 (#182, technobrat, judofyr)

## 1.3.6 (2013-03-17)

* Accept Hash that implements #path as options (#180, lawso017)
* Changed extension for CsvTemplate from '.csv' to '.rcsv' (#177, alexgb)

## 1.3.5 (2013-03-06)

* Fixed extension for PlainTemplate (judofyr)
* Improved local variables regexp (#174, razorinc)
* Added CHANGELOG.md

## 1.3.4 (2013-02-28)

* Support RDoc 4.0 (#168, judofyr)
* Add mention of Org-Mode support (#165, aslakknutsen)
* Add AsciiDoctorTemplate (#163, #164, aslakknutsen)
* Add PlainTextTemplate (nathanaeljones)
* Restrict locals to valid variable names (#158, thinkerbot)
* ERB: Improve trim mode support (#156, ssimeonov)
* Add CSVTemplate (#153, alexgb)
* Remove special case for 1.9.1 (#147, guilleiguaran)
* Add allows\_script? method to Template (#143, bhollis)
* Default to using Redcarpet2 (#139, DAddYE)
* Allow File/Tempfile as filenames (#134, jamesotron)
* Add EtanniTemplate (#131, manveru)
* Support RDoc 3.10 (#112, timfel)
* Always compile templates; remove old source evaluator (rtomayko)
* Less: Options are now being passed to the parser (#106, cowboyd)
