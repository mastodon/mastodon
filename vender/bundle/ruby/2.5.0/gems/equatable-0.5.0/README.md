# Equatable
[![Gem Version](https://badge.fury.io/rb/equatable.png)](http://badge.fury.io/rb/equatable) [![Build Status](https://secure.travis-ci.org/peter-murach/equatable.png?branch=master)][travis] [![Code Climate](https://codeclimate.com/github/peter-murach/equatable.png)][codeclimate]

[travis]: http://travis-ci.org/peter-murach/equatable
[codeclimate]: https://codeclimate.com/github/peter-murach/equatable

Allows ruby objects to implement equality comparison and inspection methods.

By including this module, a class indicates that its instances have explicit general contracts for `hash`, `==` and `eql?` methods. Specifically `eql?` contract requires that it implements an equivalence relation. By default each instance of the class is equal only to itself. This is a right behaviour when you have distinct objects. Howerver, it is the responsibility of any class to clearly define their equality. Failure to do so may prevent instances to behave as expected when for instance `Array#uniq` is invoked or when they are used as `Hash` keys.

## Installation

Add this line to your application's Gemfile:

    gem 'equatable'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install equatable

## Usage

It is assumed that your objects are value objects and the only values that affect equality comparison are the ones specified by your attribute readers. Each attribute reader should be a significant field in determining objects values.

```ruby
class Point
  include Equatable

  attr_reader :x, :y

  def initialize(x, y)
    @x, @y = x, y
  end
end

point_1 = Point.new(1, 1)
point_2 = Point.new(1, 1)
point_3 = Point.new(1, 2)

point_1 == point_2            # => true
point_1.hash == point_2.hash  # => true
point_1.eql?(point_2)         # => true
point_1.equal?(point_2)       # => false

point_1 == point_3            # => false
point_1.hash == point_3.hash  # => false
point_1.eql?(point_3)         # => false
point_1.equal?(point_3)       # => false

point_1.inspect  # => "#<Point x=1 y=1>"
```

## Attributes

It is important that the attribute readers should allow for performing deterministic computations on class instances. Therefore you should avoid specifying attributes that depend on unreliable resources like IP address that require network access.

## Subtypes

**Equatable** ensures that any important property of a type holds for its subtypes. However, please note that adding an extra attribute reader to a subclass will violate the equivalence contract, namely, the superclass will be equal to the subclass but reverse won't be true. For example:

```ruby
class ColorPoint < Point
  attr_reader :color

  def initialize(x, y, color)
    super(x, y)
    @color = color
  end
end

point = Point.new(1, 1)
color_point = ColorPoint.new(1, 1, :red)

point == color_point            # => true
color_point == point            # => false

point.hash == color_point.hash  # => false
point.eql?(color_point)         # => false
point.equal?(color_point)       # => false
```

The `ColorPoint` class demonstrates that extending a class with extra value property does not preserve the `equals` contract.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## Copyright

Copyright (c) 2012-2014 Piotr Murach. See LICENSE for further details.
