# Climate Control

Easily manage your environment.

## Installation

Add this line to your application's Gemfile:

    gem 'climate_control'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install climate_control

## Usage

Climate Control can be used to temporarily assign environment variables
within a block:

```ruby
ClimateControl.modify CONFIRMATION_INSTRUCTIONS_BCC: 'confirmation_bcc@example.com' do
  sign_up_as 'john@example.com'
  confirm_account_for_email 'john@example.com'
  current_email.should bcc_to('confirmation_bcc@example.com')
end
```

To use with RSpec, you could define this in your spec:

```ruby
def with_modified_env(options, &block)
  ClimateControl.modify(options, &block)
end
```

This would allow for more straightforward way to modify the environment:

```ruby
require 'spec_helper'

describe Thing, 'name' do
  it 'appends ADDITIONAL_NAME' do
    with_modified_env ADDITIONAL_NAME: 'bar' do
      expect(Thing.new.name).to eq('John Doe Bar')
    end
  end

  def with_modified_env(options, &block)
    ClimateControl.modify(options, &block)
  end
end
```

To modify the environment for an entire set of tests in RSpec, use an `around`
block:

```ruby
describe Thing, 'name' do
  # ... tests

  around do |example|
    ClimateControl.modify FOO: 'bar' do
      example.run
    end
  end
end
```

Environment variables assigned within the block will be preserved;
essentially, the code should behave exactly the same with and without the
block, except for the overrides. Transparency is crucial because the code
executed within the block is not for `ClimateControl` to manage or modify. See
the tests for more detail about the specific behaviors.

## Why Use Climate Control?

By following guidelines regarding environment variables outlined by the
[twelve-factor app](http://12factor.net/config), testing code in an isolated
manner becomes more difficult:

* avoiding modifications and testing values, we introduce mystery guests
* making modifications and testing values, we introduce risk as environment
  variables represent global state

Climate Control modifies environment variables only within the context of the
block, ensuring values are managed properly and consistently.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## License

climate_control is copyright 2012-2017 Joshua Clayton and thoughtbot, inc. It is free software and may be redistributed under the terms specified in the [LICENSE.txt](https://github.com/thoughtbot/climate_control/blob/master/LICENSE.txt) file.
