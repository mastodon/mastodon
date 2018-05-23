# Nyaaaan

Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/nyaaaan`. To experiment with that code, run `bin/console` for an interactive prompt.

TODO: Delete this and the text above, and describe your gem

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'nyaaaan'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install nyaaaan

## Usage

- Make initializers file  
config\initializers\mastodon_command.rb

```ruby
Nyaaaan.setup do |status|	
  	
    # 社会性フィルター機能	
    nyaaaan = Nyaaaan::Lang.new('[ 　\n]?#(社会性フィルター)[ 　\n]?', [	
      {	
        pattern: '死ね',	
        replace: 'にゃーん'	
      },	
  	
    ])	
    status = nyaaaan.convert(status) if nyaaaan.match(status)	
    status	
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/nyaaaan. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Nyaaaan project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/nyaaaan/blob/master/CODE_OF_CONDUCT.md).
