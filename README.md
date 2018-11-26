# Profanityfilter

This is version 2 of a PHP experiment which was an attempt at creating an accurate profanity filter.
This filter will not only filter a direct match, it takes in to account profane words split by spaces.
It also considers profane words which include symbols to replace normal characters and duplicate letters.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'profanityfilter'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install profanityfilter

## Usage

Simply call

```ruby
Profanityfilter.sanitize string
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rspec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/cjmarkham/profanityfilter.
