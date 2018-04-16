# mime-types-data

* home :: https://github.com/mime-types/mime-types-data/
* code :: https://github.com/mime-types/mime-types-data/
* issues :: https://github.com/mime-types/mime-types-data/issues

## Description

mime-types-data provides a registry for information about MIME media type
definitions. It can be used with the Ruby mime-types library or other software
to determine defined filename extensions for MIME types, or to use filename
extensions to look up the likely MIME type definitions.

### About MIME Media Types

MIME media types are used in MIME-compliant communications, as in e-mail or
HTTP traffic, to indicate the type of content which is transmitted. The
registry provided in mime-types-data contains detailed information about MIME
entities. There are many types defined by RFCs and vendors, so the list is long
but invariably; don't hesitate to offer additional type definitions for
consideration. MIME type definitions found in mime-types are from RFCs, W3C
recommendations, the [IANA Media Types registry][registry], and user
contributions. It conforms to RFCs 2045 and 2231.

### Data Formats Supported in this Registry

This registry contains the MIME media types in three formats:

*   A YAML format matching the Ruby mime-types library objects (MIME::Type).
    This is the primary user-editable format.
*   A JSON format converted from the YAML format. Prior to Ruby mime-types 3.0,
    this was the main consumption format and is still recommended for any
    implementation that does not wish to implement the columnar format.
*   An encoded text format splitting the data for each MIME type across
    multiple files. This columnar data format reduces the minimal data load
    substantially, resulting in a performance improvement at the cost of more
    complex code for loading the data on-demand. This is the default format for
    Ruby mime-types 3.0.

## mime-types-data Modified Semantic Versioning

mime-types-data uses a heavily modified [Semantic Versioning][] scheme to
indicate that the data formats compatibility based on a `SCHEMA` version and
the date of the data update: `SCHEMA.YEAR.MONTHDAY`.

1.  If an incompatible data format change is made to any of the supported
    formts, `SCHEMA` will be incremented. The current `SCHEMA` is 3, supporting
    the YAML, JSON, and columnar formats required for Ruby mime-types 3.0.

2.  When the data is updated, the `YEAR.MONTHDAY` combination will be updated.
    An update on the last day of October 2015 would be written as `2015.1031`,
    resulting in the full version of `3.2015.1031`.

3.  If multiple versions of the data need to be released on the same day due to
    error, there will be an additional `REVISION` field incremented on the end
    of the version. Thus, if three revisions need to be published on October
    31st, 2015, the last release would be `3.2015.1031.2` (remember that the
    first release has an implied `0`.)

[registry]: https://www.iana.org/assignments/media-types/media-types.xhtml
[Semantic Versioning]: http://semver.org/
