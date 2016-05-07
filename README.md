# RPS Challenge

Gems
-------
source 'https://rubygems.org'

ruby '2.3.0'

gem 'dm-postgres-adapter'
gem 'data_mapper'
gem 'sinatra'
gem 'rspec-sinatra'
gem 'rake'
gem 'bcrypt'
gem 'sinatra-flash'

group :test do
  gem 'database_cleaner'
  gem 'rspec'
  gem 'capybara'
  gem 'byebug'
ende

Instructions
-------
**Step 1 Basic structure**

```sh
$ git clone git@github.com:makersacademy/chitter-challenge.git
$ cd chitter-challenge
$ bundle
$ rspec-sinatra init --app Chitter chitter.rb
$ mkdir app
$ cd app
$ mkdir models
$ mkdir views
$ cd ..
$ cd spec
$ mkdir feature
$ cd ..
```

make two servers in psql

insert this into rakefile
```
require 'data_mapper'
require './app/app.rb'

namespace :db do
  desc "Non destructive upgrade"
  task :auto_upgrade do
    DataMapper.auto_upgrade!
    puts "Auto-upgrade complete (no data loss)"
  end


  desc "Destructive upgrade"
  task :auto_migrate do
    DataMapper.auto_migrate!
    puts "Auto-migrate complete (data was lost)"
  end
end
```
make config.ru file
```
require 'rubygems'
require './app/app.rb'

run Chitter
```
make data_mapper_setup.rb
```
require 'data_mapper'
require 'dm-postgres-adapter'

require_relative 'models/user'

DataMapper.setup(:default, ENV['DATABASE_URL'] || "postgres://localhost/chitter_#{ENV['RACK_ENV']}")
DataMapper.finalize
```
replaced spec_helper.rb this way i can clean my tests
```
# Generated by rspec-sinatra. (2016-05-04 13:29:28 +0200)

ENV['RACK_ENV'] = 'test'

require File.join(File.dirname(__FILE__), '..', './app/app.rb')

require 'capybara'
require 'capybara/rspec'
require 'rspec'
require 'tilt/erb'
require './app/data_mapper_setup'
require 'web_helper'

Capybara.app = BookmarkManager

require 'database_cleaner'

# DatabaseCleaner.strategy = :truncation

# hmm - should be generated by `rspec --init` directly rather than copy paste ...

# This file was generated by the `rspec --init` command. Conventionally, all
# specs live under a `spec` directory, which RSpec adds to the `$LOAD_PATH`.
# The generated `.rspec` file contains `--require spec_helper` which will cause this
# file to always be loaded, without a need to explicitly require it in any files.
#
# Given that it is always loaded, you are encouraged to keep this file as
# light-weight as possible. Requiring heavyweight dependencies from this file
# will add to the boot time of your test suite on EVERY test run, even for an
# individual file that may not need all of that loaded. Instead, consider making
# a separate helper file that requires the additional dependencies and performs
# the additional setup, and require it from the spec files that actually need it.
#
# The `.rspec` file also contains a few flags that are not defaults but that
# users commonly want.
#
# See http://rubydoc.info/gems/rspec-core/RSpec/Core/Configuration
RSpec.configure do |config|
  config.include Capybara::DSL
  # rspec-expectations config goes here. You can use an alternate
  # assertion/expectation library such as wrong or the stdlib/minitest
  # assertions if you prefer.
  config.expect_with :rspec do |expectations|
    # This option will default to `true` in RSpec 4. It makes the `description`
    # and `failure_message` of custom matchers include text for helper methods
    # defined using `chain`, e.g.:
    # be_bigger_than(2).and_smaller_than(4).description
    #   # => "be bigger than 2 and smaller than 4"
    # ...rather than:
    #   # => "be bigger than 2"
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  # rspec-mocks config goes here. You can use an alternate test double
  # library (such as bogus or mocha) by changing the `mock_with` option here.
  config.mock_with :rspec do |mocks|
    # Prevents you from mocking or stubbing a method that does not exist on
    # a real object. This is generally recommended, and will default to
    # `true` in RSpec 4.
    mocks.verify_partial_doubles = true
  end

  # CLEAR TEST DATABASE
  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
  end

  # Everything in this block runs once before each individual test
  config.before(:each) do
    DatabaseCleaner.start
  end

  # Everything in this block runs once after each individual test
  config.after(:each) do
    DatabaseCleaner.clean
  end

# The settings below are suggested to provide a good initial experience
# with RSpec, but feel free to customize to your heart's content.
=begin
  # These two settings work together to allow you to limit a spec run
  # to individual examples or groups you care about by tagging them with
  # `:focus` metadata. When nothing is tagged with `:focus`, all examples
  # get run.
  config.filter_run :focus
  config.run_all_when_everything_filtered = true

  # Limits the available syntax to the non-monkey patched syntax that is recommended.
  # For more details, see:
  #   - http://myronmars.to/n/dev-blog/2012/06/rspecs-new-expectation-syntax
  #   - http://teaisaweso.me/blog/2013/05/27/rspecs-new-message-expectation-syntax/
  #   - http://myronmars.to/n/dev-blog/2014/05/notable-changes-in-rspec-3#new__config_option_to_disable_rspeccore_monkey_patching
  config.disable_monkey_patching!

  # This setting enables warnings. It's recommended, but in some cases may
  # be too noisy due to issues in dependencies.
  config.warnings = true

  # Many RSpec users commonly either run the entire suite or an individual
  # file, and it's useful to allow more verbose output when running an
  # individual spec file.
  if config.files_to_run.one?
    # Use the documentation formatter for detailed output,
    # unless a formatter has already been configured
    # (e.g. via a command-line flag).
    config.default_formatter = 'doc'
  end

  # Print the 10 slowest examples and example groups at the
  # end of the spec run, to help surface which specs are running
  # particularly slow.
  config.profile_examples = 10

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = :random

  # Seed global randomization in this process using the `--seed` CLI option.
  # Setting this allows you to use `--seed` to deterministically reproduce
  # test failures related to randomization by passing the same `--seed` value
  # as the one that triggered the failure.
  Kernel.srand config.seed
=end
end

```
create my app.rb file in app folder
```
ENV['RACK_ENV'] ||= 'development'

require 'sinatra/base'
require_relative 'data_mapper_setup'
require 'sinatra/flash'


class Chitter < Sinatra::Base
  use Rack::MethodOverride
  enable :sessions
  set :session_secret, 'super secret'
  register Sinatra::Flash

end


```


add my web_helper.rb from BookmarkManager
```
def sign_up(email:'alice@example.com', password:'oranges!', password_confirmation:'oranges!')
  visit '/users/new'
  expect(page.status_code).to eq(200)
  fill_in :email,    with: email
  fill_in :password, with: password
  fill_in :password_confirmation, with: password_confirmation
  click_button 'Sign up'
end

def sign_in(email:'alice@example.com', password:'oranges!')
  visit '/sessions/new'
  fill_in :email, with: email
  fill_in :password, with: password
  click_button 'Sign in'
end

```






Chitter Challenge
=================

* Challenge time: rest of the day and weekend, until Monday 9am
* Feel free to use google, your notes, books, etc. but work on your own
* If you refer to the solution of another coach or student, please put a link to that in your README
* If you have a partial solution, **still check in a partial solution**
* You must submit a pull request to this repo with your code by 9am Monday morning

Challenge:
-------

As usual please start by forking this repo.

We are going to write a little Twitter clone that will allow the users to post messages to a public stream.

Features:
-------

```
As a Maker
So that I can post messages on Chitter as me
I want to sign up for Chitter

As a Maker
So that I can post messages on Chitter as me
I want to log in to Chitter

As a Maker
So that I can avoid others posting messages on Chitter as me
I want to log out of Chitter

As a Maker
So that I can let people know what I am doing  
I want to post a message (peep) to chitter

As a maker
So that I can see what others are saying  
I want to see all peeps in reverse chronological order

As a maker
So that I can better appreciate the context of a peep
I want to see the time at which it was made
```

Notes on functionality:
------

* Drive the creation of your app using tests - either cucumber or rspec as you prefer
* Makers sign up to chitter with their email, password, name and a user name (e.g. sam@makersacademy.com, s3cr3t, Samuel Russell Hampden Joseph, tansaku).
* The username and email are unique.
* Peeps (posts to chitter) have the name of the maker and their user handle.
* Use bcrypt to secure the passwords.
* Use data mapper and postgres to save the data.
* You don't have to be logged in to see the peeps.
* You only can peep if you are logged in.
* Please ensure that you update your README to indicate the technologies used, and give instructions on how to install and run the tests
* Finally submit a pull request before Monday at 9am with your solution or partial solution.  However much or little amount of code you wrote please please please submit a pull request before Monday at 9am

Bonus:
-----

If you have time you can implement the following:

* In order to start a conversation as a maker I want to reply to a peep from another maker.

And/Or:

* Work on the css to make it look good (we all like beautiful things).

Good luck and let the chitter begin!

Code Review
-----------

In code review we'll be hoping to see:

* All tests passing
* High [Test coverage](https://github.com/makersacademy/course/blob/master/pills/test_coverage.md) (>95% is good)
* The code is elegant: every class has a clear responsibility, methods are short etc.

Reviewers will potentially be using this [code review rubric](docs/review.md).  Referring to this rubric in advance may make the challenge somewhat easier.  You should be the judge of how much challenge you want this weekend.

Notes on test coverage
----------------------

Please ensure you have the following **AT THE TOP** of your spec_helper.rb in order to have test coverage stats generated
on your pull request:

```ruby
require 'coveralls'
require 'simplecov'

SimpleCov.formatters = [
  SimpleCov::Formatter::HTMLFormatter,
  Coveralls::SimpleCov::Formatter
]
Coveralls.wear!
```

You can see your [test coverage](https://github.com/makersacademy/course/blob/master/pills/test_coverage.md) when you submit a pull request, and you can also get a summary locally by running:

```
$ coveralls report
```

This repo works with [Coveralls](https://coveralls.io/) to calculate test coverage statistics on each pull request.
