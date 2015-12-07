[![Build Status](https://travis-ci.com/Acornsgrow/rack-vitals.svg?token=4fvrruF3QcAS3qNYjLiE)](https://travis-ci.com/Acornsgrow/rack-vitals)
[![Code Climate](https://codeclimate.com/repos/565f493f9769c16d57000dfa/badges/faec219f166eb3cb676e/gpa.svg)](https://codeclimate.com/repos/565f493f9769c16d57000dfa/feed)
[![Test Coverage](https://codeclimate.com/repos/565f493f9769c16d57000dfa/badges/faec219f166eb3cb676e/coverage.svg)](https://codeclimate.com/repos/565f493f9769c16d57000dfa/coverage)

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

#### Add `rack-vitals` to your middleware stack.

##### Rack app

```ruby
# config.ru
require 'rack/vitals'

use Rack::Vitals
run YourApp
```

##### Lotus

You can read about rails middleware in their [guide](http://lotusrb.org/guides/actions/rack-integration/).

In `config.ru`, same as a [Rack app](#rack-app).

##### Rails

You can read about rails middleware in their [guide](http://guides.rubyonrails.org/rails_on_rack.html).

```ruby
# config/application.rb
config.middleware.use Rack::Vitals
```

#### Declare the dependencies, if any, that you'd like to be checked.

```ruby
Rack::Vitals.register_checks do
  check "name of dependency", critical: true do
    if "some logic to check dependency"
      up
    else
      down
    end
  end

  check "name of dependency" do
    if "some logic to check dependency"
      up
    elsif "some other logic"
      warn
    else
      down
    end
  end
end
```

Declare one `Rack::Vitals.register_checks` block to hold all of your declared checks.

* ##### `register_checks`
  * `register_checks` takes a block where all `check` definitions are
    declared.

You can define a new check by using the `check` method within the block.

* ##### `check`
  * `check` needs a name to identify it in the `/status` check.
    ```ruby
    check "name of check here" do
    end
    ```

  * You can pass an optional argument of `critical: true` to have the check run
  for each `/health` request. This will cause the `/health` request to fail if a
  `down` is reached.
    ```ruby
    check "name of check here", critical: true do
    end
    ```

  * `check` takes a block which defines the logic that you want to run when
    the check is processed. This block should call `up`, `warn`,
    and/or `down` based on how you'd like `/status` and `/health` to
    report the checks.
    ```ruby
    check "name", critical: true do
      # Do whatever logic you want to check
      if true
        up
      else
        down
      end
    end
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

