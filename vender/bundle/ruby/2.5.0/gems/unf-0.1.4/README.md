ruby-unf
========

Synopsis
--------

* A wrapper library to bring Unicode Normalization Form support to Ruby/JRuby

Description
-----------

* Uses `unf_ext` on CRuby and `java.text.Normalizer` on JRuby.

* Normalizes UTF-8 strings into and from NFC, NFD, NFKC or NFKD

        # For bulk conversion
        normalizer = UNF::Normalizer.instance
        a_bunch_of_strings.map! { |string|
          normalizer.normalize(string, :nfc) #=> string in NFC
        }

        # Class method
        UNF::Normalizer.normalize(string, :nfc)

        # Instance methods of String
        string.to_nfc

Installation
------------

	gem install unf

License
-------

Copyright (c) 2011, 2012, 2013 Akinori MUSHA

Licensed under the 2-clause BSD license.
See `LICENSE` for details.
