# Mobility. Typed.

[![Ruby](https://github.com/GeorgeGorbanev/mobility_typed/actions/workflows/ruby.yml/badge.svg)](https://github.com/GeorgeGorbanev/mobility_typed/actions/workflows/ruby.yml)
[![Gem Version](https://badge.fury.io/rb/mobility_typed.svg)](https://badge.fury.io/rb/mobility_typed)

This gem contains plugin for [Mobility](https://github.com/shioyama/mobility) translation framework. 
It provides type checking for attribute writers.

## Motivation

Since Mobility supports different storage backends some of them will not
guarantee type safety of input data. For example Postgres
([`Mobility::Backend::Jsonb`](http://www.rubydoc.info/gems/mobility/Mobility/Backends/Jsonb)
let us to save any kind of json-based data in single column.

```ruby
class Offer < ApplicationRecord
  # ...
   
  translates :benefits
end

Offer.create!(benefits: ['fast', 'safe'])
Offer.create!(benefits: 'cheap')

Offer.find_each do |offer|
  offer.benefits.each { |benefit| Customer.notify_by_benefit(benefit) }
  # => NoMethodError (undefined method `each' for "cheap":String)
end
```

To prevent errors like this or at least detect them earlier we can add
`:type` option to attribute writer configuration:

```ruby
class Offer < ApplicationRecord
  # ...
   
  translates :benefits, writer: { type: :array }
end

Offer.create!(benefits: ['fast', 'safe'])
Offer.create!(benefits: 'cheap')
# => MobilityTyped::Writer::TypeError ("benefits= called with string, array expected")
# now error exposed before database records was corrupted
# so we can fix it earlier and code below will executes safely 
Offer.find_each do |offer|
  offer.benefits.each { |benefit| Customer.notify_by_benefit(benefit) }
end
```

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'mobility_typed'
```

And then execute:

```sh
$ bundle install
```

Then add plugin to your mobility initializer:

```ruby
# your_rails_app/config/initializers/mobility.rb
Mobility.configure do
  # ...
  plugins do
    # ...
    typed_writer
    # ...
  end
  # ...
end
```
And remove `writer` plugin from your model if you have it:

```ruby
Mobility.configure do
  # ...
    plugins do
      # ...
        writer # <---- remove this line
      # ...
    end
  # ...
end
```

## Usage

Just add `type` option to attribute writer configuration:

```ruby
class YourModel < ApplicationRecord
  translates :your_attribute, writer: { type: :integer }
end
```

List of available writers types:
1) `:string`
2) `:integer`
3) `:float`
4) `:bool`
5) `:array`
6) `:hash`

## Default Mobility::Plugins::Writer compatibility

To use `typed_writer` plugin you should remove `writer` plugin from your initializer. 
But `typed_writer` plugin is backward compatible with `writer` plugin. You can translate attributes 
without passing `type` option to writer configuration. In this case `typed_writer` will work just as `writer` plugin.


## TODO:

1) Type checking for nested attributes, to check `array` and `hash` content
2) RBS generator
