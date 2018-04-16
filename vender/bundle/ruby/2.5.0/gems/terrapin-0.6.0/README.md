# Terrapin [![Build Status](https://secure.travis-ci.org/thoughtbot/terrapin.png?branch=master)](http://travis-ci.org/thoughtbot/terrapin)

Run shell commands safely, even with user-supplied values

[API reference](http://rubydoc.info/gems/terrapin/)

## Usage

The basic, normal stuff:

```ruby
line = Terrapin::CommandLine.new("echo", "hello 'world'")
line.command # => "echo hello 'world'"
line.run # => "hello world\n"
```

Interpolated arguments:

```ruby
line = Terrapin::CommandLine.new("convert", ":in -scale :resolution :out")
line.command(in: "omg.jpg",
             resolution: "32x32",
             out: "omg_thumb.jpg")
# => "convert 'omg.jpg' -scale '32x32' 'omg_thumb.jpg'"
```

It prevents attempts at being bad:

```ruby
line = Terrapin::CommandLine.new("cat", ":file")
line.command(file: "haha`rm -rf /`.txt") # => "cat 'haha`rm -rf /`.txt'"

line = Terrapin::CommandLine.new("cat", ":file")
line.command(file: "ohyeah?'`rm -rf /`.ha!") # => "cat 'ohyeah?'\\''`rm -rf /`.ha!'"
```

NOTE: It only does that for arguments interpolated via `run`, NOT arguments
passed into `new` (see 'Security' below):

```ruby
line = Terrapin::CommandLine.new("echo", "haha`whoami`")
line.command # => "echo haha`whoami`"
line.run # => "hahawebserver\n"
```

This is the right way:

```ruby
line = Terrapin::CommandLine.new("echo", "haha:whoami")
line.command(whoami: "`whoami`") # => "echo haha'`whoami`'"
line.run(whoami: "`whoami`") # => "haha`whoami`\n"
```

You can ignore the result:

```ruby
line = Terrapin::CommandLine.new("noisy", "--extra-verbose", swallow_stderr: true)
line.command # => "noisy --extra-verbose 2>/dev/null"

# ... and on Windows...
line.command # => "noisy --extra-verbose 2>NUL"
```

If your command errors, you get an exception:

```ruby
line = Terrapin::CommandLine.new("git", "commit")
begin
  line.run
rescue Terrapin::ExitStatusError => e
  e.message # => "Command 'git commit' returned 1. Expected 0"
end
```

If your command might return something non-zero, and you expect that, it's cool:

```ruby
line = Terrapin::CommandLine.new("/usr/bin/false", "", expected_outcodes: [0, 1])
begin
  line.run
rescue Terrapin::ExitStatusError => e
  # => You never get here!
end
```

You don't have the command? You get an exception:

```ruby
line = Terrapin::CommandLine.new("lolwut")
begin
  line.run
rescue Terrapin::CommandNotFoundError => e
  e # => the command isn't in the $PATH for this process.
end
```

But don't fear, you can specify where to look for the command:

```ruby
Terrapin::CommandLine.path = "/opt/bin"
line = Terrapin::CommandLine.new("lolwut")
line.command # => "lolwut", but it looks in /opt/bin for it.
```

You can even give it a bunch of places to look:

```ruby
    FileUtils.rm("/opt/bin/lolwut")
    File.open('/usr/local/bin/lolwut') {|f| f.write('echo Hello') }
    Terrapin::CommandLine.path = ["/opt/bin", "/usr/local/bin"]
    line = Terrapin::CommandLine.new("lolwut")
    line.run # => prints 'Hello', because it searches the path
```

Or just put it in the command:

```ruby
line = Terrapin::CommandLine.new("/opt/bin/lolwut")
line.command # => "/opt/bin/lolwut"
```

You can see what's getting run. The 'Command' part it logs is in green for
visibility! (where applicable)

```ruby
line = Terrapin::CommandLine.new("echo", ":var", logger: Logger.new(STDOUT))
line.run(var: "LOL!") # => Logs this with #info -> Command :: echo 'LOL!'
```

Or log every command:

```ruby
Terrapin::CommandLine.logger = Logger.new(STDOUT)
Terrapin::CommandLine.new("date").run # => Logs this -> Command :: date
```

## Security

Short version: Only pass user-generated data into the `run` method and NOT
`new`.

As shown in examples above, Terrapin will only shell-escape what is passed in as
interpolations to the `run` method. It WILL NOT escape what is passed in to the
second argument of `new`. Terrapin assumes that you will not be manually
passing user-generated data to that argument and will be using it as a template
for your command line's structure.

## POSIX Spawn

You can potentially increase performance by installing [the posix-spawn
gem](https://rubygems.org/gems/posix-spawn). This gem can keep your
application's heap from being copied when forking command line
processes. For applications with large heaps the gain can be
significant. To include `posix-spawn`, simply add it to your `Gemfile` or,
if you don't use bundler, install the gem.

## Runners

Terrapin will attempt to choose from among 3 different ways of running commands.
The simplest is using backticks, and is the default in 1.8. In Ruby 1.9, it
will attempt to use `Process.spawn`. And, as mentioned above, if the
`posix-spawn` gem is installed, it will attempt to use that. If for some reason
one of the `.spawn` runners don't work for you, you can override them manually
by setting a new runner, like so:

```ruby
Terrapin::CommandLine.runner = Terrapin::CommandLine::BackticksRunner.new
```

And if you really want to, you can define your own Runner, though I can't
imagine why you would.

### JRuby issues

#### Caveat

If you get `Error::ECHILD` errors and are using JRuby, there is a very good
chance that the error is actually in JRuby. This was brought to our attention
in https://github.com/thoughtbot/terrapin/issues/24 and probably fixed in
http://jira.codehaus.org/browse/JRUBY-6162. You *will* want to use the
`BackticksRunner` if you are unable to update JRuby.

#### Spawn warning

If you get `unsupported spawn option: out` warning (like in [issue
38](https://github.com/thoughtbot/terrapin/issues/38)), try to use
`PopenRunner`:

```ruby
Terrapin::CommandLine.runner = Terrapin::CommandLine::PopenRunner.new
```

## Thread Safety

Terrapin should be thread safe. As discussed [here, in this climate_control
thread](https://github.com/thoughtbot/climate_control/pull/11), climate_control,
which modifies the environment under which commands are run for the
BackticksRunner and PopenRunner, is thread-safe but not reentrant. Please let us
know if you find this is ever not the case.

## Feedback

*Security* concerns must be privately emailed to
[security@thoughtbot.com](security@thoughtbot.com).

Question? Idea? Problem? Bug? Comment? Concern? Like using question marks?

[GitHub Issues For All!](https://github.com/thoughtbot/terrapin/issues)

## Credits

Thank you to all [the
contributors](https://github.com/thoughtbot/terrapin/graphs/contributors)!

![thoughtbot](http://thoughtbot.com/logo.png)

Terrapin is maintained and funded by [thoughtbot,
inc](http://thoughtbot.com/community)

The names and logos for thoughtbot are trademarks of thoughtbot, inc.

## License

Copyright 2011-2018 Jon Yurek and thoughtbot, inc. This is free software, and
may be redistributed under the terms specified in the
[LICENSE](https://github.com/thoughtbot/terrapin/blob/master/LICENSE)
file.
