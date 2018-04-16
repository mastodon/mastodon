# MiniPortile

This documents versions 2 and up, for which the require file was
renamed to `mini_portile2`. For mini_portile versions 0.6.x and
previous, please visit
[the v0.6.x branch](https://github.com/flavorjones/mini_portile/tree/v0.6.x).

[![travis status](https://travis-ci.org/flavorjones/mini_portile.svg?branch=master)](https://travis-ci.org/flavorjones/mini_portile?branch=master)
[![appveyor status](https://ci.appveyor.com/api/projects/status/509669xx1qlhqqab/branch/master?svg=true)](https://ci.appveyor.com/project/flavorjones/mini-portile/branch/master)

* Documentation: http://www.rubydoc.info/github/flavorjones/mini_portile
* Source Code: https://github.com/flavorjones/mini_portile
* Bug Reports: https://github.com/flavorjones/mini_portile/issues

This project is a minimalistic implementation of a port/recipe system
**for developers**.

Because _"Works on my machine"_ is unacceptable for a library maintainer.


## Not Another Package Management System

`mini_portile2` is not a general package management system. It is not
aimed to replace apt, macports or homebrew.

It's intended primarily to make sure that you, as the developer of a
library, can reproduce a user's dependencies and environment by
specifying a specific version of an underlying dependency that you'd
like to use.

So, if a user says, "This bug happens on my system that uses libiconv
1.13.1", `mini_portile2` should make it easy for you to download,
compile and link against libiconv 1.13.1; and run your test suite
against it.

This scenario might be simplified with something like this:

```
rake compile LIBICONV_VERSION=1.13.1
```

(For your homework, you can make libiconv version be taken from the
appropriate `ENV` variables.)



## Sounds easy, but where's the catch?

At this time `mini_portile2` only supports **autoconf**- or
**configure**-based projects. (That is, it assumes the library you
want to build contains a `configure` script, which all the
autoconf-based libraries do.)

As of v2.2.0, there is experimental support for **CMake**-based
projects. We welcome your feedback on this, particularly for Windows
platforms.


### How to use (for autoconf projects)

Now that you know the catch, and you're still reading this, here is a
quick example:

```ruby
gem "mini_portile2", "~> 2.0.0" # NECESSARY if used in extconf.rb. see below.
require "mini_portile2"
recipe = MiniPortile.new("libiconv", "1.13.1")
recipe.files = ["http://ftp.gnu.org/pub/gnu/libiconv/libiconv-1.13.1.tar.gz"]
recipe.cook
recipe.activate
```

The gem version constraint makes sure that your extconf.rb is
protected against possible backwards-incompatible changes to
`mini_portile2`. This constraint is REQUIRED if you're using
`mini_portile2` within a gem installation process (e.g., extconf.rb),
because Bundler doesn't enforce gem version constraints at
install-time (only at run-time.

`#cook` will download, extract, patch, configure and compile the
library into a namespaced structure.

`#activate` ensures GCC will find this library and prefer it over a
system-wide installation.


### How to use (for cmake projects)

Same as above, but instead of `MiniPortile.new`, call `MiniPortileCMake.new`.


### Directory Structure Conventions

`mini_portile2` follows the principle of **convention over configuration** and
established a folder structure where is going to place files and perform work.

Take the above example, and let's draw some picture:

```
mylib
  |-- ports
  |   |-- archives
  |   |   `-- libiconv-1.13.1.tar.gz
  |   `-- <platform>
  |       `-- libiconv
  |           `-- 1.13.1
  |               |-- bin
  |               |-- include
  |               `-- lib
  `-- tmp
      `-- <platform>
          `-- ports
```

In above structure, `<platform>` refers to the architecture that
represents the operating system you're using (e.g. i686-linux,
i386-mingw32, etc).

Inside the platform folder, `mini_portile2` will store the artifacts
that result from the compilation process. The library is versioned so
you can keep multiple versions around on disk without clobbering
anything.

`archives` is where downloaded source files are cached. It is
recommended you avoid trashing that folder to avoid downloading the
same file multiple times (save bandwidth, save the world).

`tmp` is where compilation is performed and can be safely discarded.

Use the recipe's `#path` to obtain the full path to the installation
directory:

```ruby
recipe.cook
recipe.path # => /home/luis/projects/myapp/ports/i686-linux/libiconv/1.13.1
```

### How can I combine this with my compilation task?

In the simplest case, your rake `compile` task will depend on
`mini_portile2` compilation and most important, activation.

Example:

```ruby
task :libiconv do
  recipe = MiniPortile.new("libiconv", "1.13.1")
  recipe.files << {
    url: "http://ftp.gnu.org/pub/gnu/libiconv/libiconv-1.13.1.tar.gz"],
    sha256: "55a36168306089009d054ccdd9d013041bfc3ab26be7033d107821f1c4949a49"
  }
  checkpoint = ".#{recipe.name}-#{recipe.version}.installed"

  unless File.exist?(checkpoint)
    recipe.cook
    touch checkpoint
  end

  recipe.activate
end

task :compile => [:libiconv] do
  # ... your library's compilation task ...
end
```

The above example will:

* **download** and verify integrity the sources only once
* **compile** the library only once (using a timestamp file)
* ensure compiled library is **activated**
* make the compile task depend upon compiled library activation

As an exercise for the reader, you could specify the libiconv version
in an environment variable or a configuration file.

### Download verification
MiniPortile supports HTTPS, HTTP, FTP and FILE sources for download.
The integrity of the downloaded file can be verified per hash value or PGP signature.
This is particular important for untrusted sources (non-HTTPS).

#### Hash digest verification
MiniPortile can verify the integrity of the downloaded file per SHA256, SHA1 or MD5 hash digest.

```ruby
  recipe.files << {
    url: "http://your.host/file.tar.bz2",
    sha256: "<32 byte hex value>",
  }
```

#### PGP signature verification
MiniPortile can also verify the integrity of the downloaded file per PGP signature.

```ruby
  public_key = <<-EOT
    -----BEGIN PGP PUBLIC KEY BLOCK-----
    Version: GnuPG v1

    mQENBE7SKu8BCADQo6x4ZQfAcPlJMLmL8zBEBUS6GyKMMMDtrTh3Yaq481HB54oR
    [...]
    -----END PGP PUBLIC KEY BLOCK-----
  EOT

  recipe.files << {
    url: "http://your.host/file.tar.bz2",
    gpg: {
      key: public_key,
      signature_url: "http://your.host/file.tar.bz2.sig"
    }
  }
```

Please note, that the `gpg` executable is required to verify the signature.
It is therefore recommended to use the hash verification method instead of PGP, when used in `extconf.rb` while `gem install`.

### Native and/or Cross Compilation

The above example covers the normal use case: compiling dependencies
natively.

`MiniPortile` also covers another use case, which is the
cross-compilation of the dependencies to be used as part of a binary
gem compilation.

It is the perfect complementary tool for
[`rake-compiler`](https://github.com/rake-compiler/rake-compiler) and
its `cross` rake task.

Depending on your usage of `rake-compiler`, you will need to use
`host` to match the installed cross-compiler toolchain.

Please refer to the examples directory for simplified and practical usage.


### Supported Scenarios

As mentioned before, `MiniPortile` requires a GCC compiler
toolchain. This has been tested against Ubuntu, OSX and even Windows
(RubyInstaller with DevKit)


## License

This library is licensed under MIT license. Please see LICENSE.txt for details.
