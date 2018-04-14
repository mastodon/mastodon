=== 2.0.0 / 2013-12-21

- Drop Ruby 1.8 compatibility
- GH #21: Fix FilePart length calculation for Ruby 1.9 when filename contains
  multibyte characters (hexfet)
- GH #20: Ensure upload responds to both #content_type and #original_filename
  (Steven Davidovitz)
- GH #31: Support setting headers on any part of the request (Socrates Vicente)
- GH #30: Support array values for params (Gustav Ernberg)
- GH #32: Fix respond_to? signature (Leo Cassarani)
- GH #33: Update README to markdown (Jagtesh Chadha)
- GH #35: Improved handling of array-type parameters (Steffen Grunwald)

=== 1.2.0 / 2013-02-25

- #25: Ruby 2 compatibility (thanks mislav)

=== 1.1.5 / 2012-02-12

- Fix length/bytesize of parts in 1.9 (#7, #14) (Jason Moore)
- Allow CompositeIO objects to be re-read by rewinding, like other IO
  objects. (Luke Redpath)

=== 1.1.4 / 2011-11-23

- Non-functional changes in release (switch to Bundler gem tasks)

=== 1.1.3 / 2011-07-25

- More configurable header specification for parts (Gerrit Riessen)

=== 1.1.2 / 2011-05-24

- Fix CRLF file part miscalculation (Johannes Wagener)
- Fix Epilogue CRLF issue (suggestion by Neil Spring)

=== 1.1.1 / 2011-05-13

- GH# 9: Fixed Ruby 1.9.2 StringIO bug (thanks Alex Koppel)

=== 1.1.0 / 2011-01-11

- API CHANGE: UploadIO.convert! removed in favor of UploadIO.new
  (Jeff Hodges)

=== 1.0.1 / 2010-04-27

- Doc updates, make gemspec based on more modern Rubygems

=== 1.0 / 2009-02-12

- Many fixes from mlooney, seems to work now. Putting the 0.9 seal of
  approval on it.

=== 0.1 / 2008-08-12

* 1 major enhancement

  * Birthday!

