[![Build Status](https://travis-ci.com/Acornsgrow/rack-vitals.svg?token=4fvrruF3QcAS3qNYjLiE&branch=add_code_climate)](https://travis-ci.com/Acornsgrow/rack-vitals)
# Rack::Vitals

Vitals is a gem that adds rack middleware to your rack applications for
checking its health.

## Installation

Add this line to your application's Gemfile with your desired version number.
Be sure to have our gem source set correctly to [gemfury.com](https://gemfury.com)'s settings.

```ruby
gem "rack-vitals", "~> 0.1"
```

And then execute:

```bash
$ bundle install
```

## Usage

Add `rack-vitals` to your middleware stack.

#### Rack app

```ruby
# config.ru
require 'rack/vitals'

use Rack::Vitals
run YourApp
```

#### Lotus

You can read about rails middleware in their [guide](http://lotusrb.org/guides/actions/rack-integration/).

In `config.ru`, same as a [Rack app](#rack-app).

#### Rails

You can read about rails middleware in their [guide](http://guides.rubyonrails.org/rails_on_rack.html).

```ruby
# config/application.rb
config.middleware.use Rack::Vitals
```


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then,
run `rake spec` to run the tests.

#### Releasing a new version

- Update the version number in `version.rb`.
- Create a git tag for that version.
- Push git commits and tags.
- Run `gem build rack-vitals.gemspec`.
- Push the created `.gem` file to [gemfury.com](https://gemfury.com).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/acornsgrow/rack-vitals.

This project is intended to be a safe, welcoming space for collaboration, and
contributors are expected to adhere to the [Contributor Covenant](contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

