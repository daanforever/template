source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~>4.0.0'

# Use sqlite3 as the database for Active Record
gem 'sqlite3'

# Use SCSS for stylesheets
gem 'sass-rails', '~> 4.0.0'

# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'

# Use CoffeeScript for .js.coffee assets and views
gem 'coffee-rails', '~> 4.0.0'

# See https://github.com/sstephenson/execjs#readme for more supported runtimes
gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'

# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 1.2'

group :doc do
  # bundle exec rake doc:rails generates the API under doc/api.
  gem 'sdoc', require: false
end

gem 'twitter-bootstrap-rails'         # Twitter Bootstrap for Rails
gem 'less-rails'                      # For twitter-bootstrap-rails
gem 'awesome_print'                   # For rails console

gem 'thin'                            # Web server. Usage: rails s thin
gem 'foreman'                         # Process manager. Usage: foreman start

gem 'devise'                          # Flexible authentication solution for Rails with Warden
gem 'the_role', github: 'the-teacher/the_role' # Authorization for Rails 4 + admin UI

gem 'haml'                            # HTML Abstraction Markup Language
gem 'simple_form'                     # Forms made easy for Rails!


group :development, :test do
  gem 'railroady'               # Class diagram generator. Usage: rake diagram:all
  gem 'better_errors'           # Better errors handler
  gem 'binding_of_caller'       # For better_errors
  gem 'meta_request'            # For RailsPanel (chrome extention)
  gem 'rack-mini-profiler'      # Rails profiler
  gem 'brakeman'                # Security scanner. Usage: brakeman [-o file.html]
  gem 'bullet'                  # Query optimization # TODO need to configure
  gem 'annotate'                # Annotate ActiveRecord models. Usage: annotate
  gem 'zeus'                    # Boot any rails app in under a second.
  gem 'haml-rails'              # Integration for HAML
end

group :test do
  gem "rspec-rails"             # Test suite
  gem 'factory_girl_rails'      # Fixtures replacement
  gem 'database_cleaner'        # Helper gem for rspec
  gem 'shoulda-matchers'        # Rspec-compatible one-liners
  gem 'simplecov', require: false # Code coverage
  # gem 'capybara'                # User expirience testing
  # gem 'selenium-webdriver'      # Javascript driver for selenium
  # gem 'launchy'                 # For capybara
end
