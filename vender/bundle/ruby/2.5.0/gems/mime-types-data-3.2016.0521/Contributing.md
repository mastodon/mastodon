## Contributing

Contributions to mime-types-data is encouraged in any form: a bug report, new
MIME type defintions, or additional code to help manage the MIME types. As with
many of my projects, I have a few suggestions for improving the chance of
acceptance of your code contributions:

* The support files are written in Ruby and should remain in the coding style
  that already exists, and I use hoe for releasing the mime-types-data RubyGem.
* Use a thoughtfully-named topic branch that contains your change. Rebase your
  commits into logical chunks as necessary.
* Use [quality commit messages][qcm].
* Do not change the version number; when your patch is accepted and a release
  is made, the version will be updated at that point.
* Submit a GitHub pull request with your changes.
* New or changed behaviours require new or updated documentation.

Although mime-types-data was extracted from the [Ruby mime-types][rmt] gem and
the support files are written in Ruby, the *target* of mime-types-data is any
implementation that wishes to use the data as a MIME types registry, so I am
particularly interested in tools that will create a mime-types-data package for
other languages.

### Adding or Modifying MIME Types

The Ruby mime-types gem loads its data from files encoded in the `data`
directory in this gem by loading `mime-types-data` and reading
MIME::Types::Data::PATH. These files are compiled files from the collection of
data in the `types` directory. Pull requests that include changes to these
files will require amendment to revert these files.

New or modified MIME types should be edited in the appropriate YAML file under
`types`. The format is as shown below for the `application/xml` MIME type
in `types/application.yml`.

```yaml
  - !ruby/object:MIME::Type
    content-type: application/xml
    encoding: 8bit
    extensions:
    - xml
    - xsl
    references:
    - IANA
    - RFC3023
    xrefs: !ruby/hash:MIME::Types::Container
      rfc:
      - rfc3023
    registered: true
```

There are other fields that can be added, matching the fields discussed in the
documentation for MIME::Type. Pull requests for MIME types should just contain
the changes to the YAML files for the new or modified MIME types; I will
convert the YAML files to JSON prior to a new release. I would rather not have
to verify that the JSON matches the YAML changes, which is why it is not
necessary to convert for the pull request.

If you are making a change for a private fork, use `rake convert:yaml:json` to
convert the YAML to JSON, or `rake convert:yaml:columnar` to convert it to the
new columnar format.

#### Updating Types from the IANA or Apache Lists

If you are maintaining a private fork and wish to update your copy of the MIME
types registry used by this gem, you can do this with the rake tasks:

    $ rake mime:iana
    $ rake mime:apache

### Development Dependencies

mime-types-data uses Ryan Davis’s {Hoe}[https://github.com/seattlerb/hoe] to
manage the release process, and it adds a number of rake tasks. You will mostly
be interested in:

    $ rake

which runs the tests the same way that:

    $ rake test
    $ rake travis

will do.

To assist with the installation of the development dependencies for
mime-types-data, I have provided the simplest possible Gemfile pointing to the
(generated) `mime-types-data.gemspec` file. This will permit you to do:

    $ bundle install

to get the development dependencies. If you aleady have `hoe` installed, you
can accomplish the same thing with:

    $ rake newb

This task will install any missing dependencies, run the tests/specs, and
generate the RDoc.

You can run tests with code coverage analysis by running:

    $ rake test:coverage

### Workflow

Here's the most direct way to get your work merged into the project:

* Fork the project.
* Clone down your fork (`git clone
  git://github.com/<username>/mime-types-data.git`).
* Create a topic branch to contain your change (`git checkout -b
  my\_awesome\_feature`).
* Hack away, add tests. Not necessarily in that order.
* Make sure everything still passes by running `rake`.
* If necessary, rebase your commits into logical chunks, without errors.
* Push the branch up (`git push origin my\_awesome\_feature`).
* Create a pull request against mime-types/mime-types-data and describe what
  your change does and the why you think it should be merged.

### Contributors

* Austin Ziegler created mime-types.

Thanks to everyone else who has contributed to mime-types:

* Aaron Patterson
* Aggelos Avgerinos
* Andre Pankratz
* Andy Brody
* Arnaud Meuret
* Brandon Galbraith
* Chris Gat
* David Genord
* Eric Marden
* Garret Alfert
* Godfrey Chan
* Greg Brockman
* Hans de Graaff
* Henrik Hodne
* Jeremy Evans
* Juanito Fatas
* Łukasz Śliwa
* Keerthi Siva
* Ken Ip
* Martin d'Allens
* Mauricio Linhares
* nycvotes-dev
* Postmodern
* Richard Hirner
* Richard Hurt
* Richard Schneeman
* Tao Guo
* Tibor Szolár
* Todd Carrico

[qcm]: http://tbaggery.com/2008/04/19/a-note-about-git-commit-messages.html
[rmt]: https://github.com/mime-types/ruby-mime-types/
