file 'Gemfile', <<-CODE
source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/\#{repo}.git" }

# ruby '2.6.0'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.2.2', '>= 5.2.2.1'
# Use sqlite3 as the database for Active Record
gem 'sqlite3', '~> 1.3.6'
# Use Puma as the app server
gem 'puma', '~> 3.11'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# See https://github.com/rails/execjs#readme for more supported runtimes
gem 'mini_racer', platforms: :ruby

# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.2'
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'turbolinks', '~> 5'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.5'
# Use Redis adapter to run Action Cable in production
gem 'redis', '~> 4.0'
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use ActiveStorage variant
# gem 'mini_magick', '~> 4.8'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.1.0', require: false

gem 'jquery-rails'                    # Provides jQuery and the jQuery-ujs driver
gem 'haml'                            # HTML Abstraction Markup Language
gem 'simple_form'                     # Forms made easy for Rails!
gem 'responders'                      # A set of responders modules to dry up
gem 'settingson'                      # Settings management

gem 'http'                            # A fast Ruby HTTP client
gem 'faker'                           # A library for generating fake data

gem 'devise'                          # Flexible authentication solution for Rails with Warden
gem 'fie'                             # Frontend framework running over a WebSocket connection

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'web-console', '>= 3.3.0'       # Rails Console on the Browser
  gem 'rack-mini-profiler'            # Rails profiler
  gem 'annotate'                      # Annotate ActiveRecord models. Usage: annotate
  gem 'haml-rails'                    # Integration for HAML
  gem 'rubocop', require: false       # A Ruby static code analyzer and formatter
end

group :development, :test do
  gem 'listen', '>= 3.0.5', '< 3.2'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'spring-commands-rspec'         # Implements the rspec command for Spring
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
end

group :test do
  gem 'rspec-rails'                   # Test suite
  gem 'factory_bot_rails'             # Fixtures replacement
  gem 'database_cleaner'              # Helper gem for rspec
  gem 'simplecov', require: false     # Code coverage
  gem 'webmock', require: false       # Library for stubbing HTTP requests
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
CODE

after_bundle do

environment "
    config.assets.compile     = true

    config.generators do |g|
      g.test_framework :rspec, :views => false, :fixture => true
      g.fixture_replacement :factory_bot, :dir => 'spec/factories'
      g.template_engine :haml
      g.view_specs false
      g.helper_specs false
    end
"

generate('settingson', 'Settings')
generate('rspec:install')
generate('simple_form:install', '--bootstrap')

initializer 'assets.rb', <<-CODE
# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Add additional assets to the asset load path.
# Rails.application.config.assets.paths << Emoji.images_path
# Add Yarn node_modules folder to the asset load path.
Rails.application.config.assets.paths << Rails.root.join('node_modules')

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in the app/assets
# folder are already added.
# Rails.application.config.assets.precompile += %w( admin.js admin.css )

Rails.application.config.assets.precompile += %w(
  turbolinks.js
  devise/*
  welcome.*
)
CODE

initializer 'mini_profiler.rb', <<-CODE
if defined?(Rack::MiniProfiler)

  # Have Mini Profiler show up on the right
  Rack::MiniProfiler.config.position = 'right'

  # Have Mini Profiler start in hidden mode - display with short cut (defaulted to 'Alt+P')
  Rack::MiniProfiler.config.start_hidden = true

  Rack::MiniProfiler.config.toggle_shortcut = 'esc'
end
CODE

inside('app/helpers') do
  run 'rm application_helper.rb'
  file 'application_helper.rb', <<-CODE
module ApplicationHelper

  def active_if(section, action = nil)
    if match_controller(section, action)
      { class: 'active' }
    else
      { class: 'inactive' }
    end
  end

  def simple_form_horizontal(object, *args, &block)
    options = args.extract_options!
    simple_form_for(object, *(args << options.merge(html: { class: "form-horizontal \#{object}" }, wrapper: :horizontal_form)), &block)
  end

  protected
  def match_controller(section, action)
    (section == controller_path) and (action.nil? or action == action_name)
  end

  # def match_namespace(section)
  #   section == controller.class.parent.name.downcase
  # end

end

CODE
end

inside('app/views/layouts') do
  file 'application.html.haml', <<-CODE
!!!
%html{lang: 'en'}
  %head
    %title= content_for?(:title) ? yield(:title) : (ENV['APP_TITLE'] || Rails.application.class.parent_name)
    %meta{charset: 'utf-8'}
    %meta{content: 'IE=edge', 'http-equiv' => 'X-UA-Compatible'}
    %meta{content: 'width=device-width, initial-scale=1, shrink-to-fit=no', name: 'viewport'}
    %link{rel: "stylesheet", href: "https://stackpath.bootstrapcdn.com/bootstrap/4.1.1/css/bootstrap.min.css", integrity: "sha384-WskhaSGFgHYWDcbwN70/dfYBj47jz9qbsMId/iRN3ewGhXQFZCSftd1LZCfmhktB", crossorigin: "anonymous"}
    = stylesheet_link_tag 'application', media: 'all', 'data-turbolinks-track' => true
    = stylesheet_link_tag controller_path, media: 'all', 'data-turbolinks-track' => true
    = javascript_include_tag 'turbolinks', 'data-turbolinks-track' => 'reload'
    = csrf_meta_tags
  %body
    .container-fluid
      = render 'layouts/navbar'
    = yield :header
    .container{style: 'height: 4em;'}
      = render 'layouts/messages'
    .container
      - if controller.class.parent == Devise
        = yield
      - else
        = render template: 'layouts/fie'
    %script{src: "https://code.jquery.com/jquery-3.3.1.slim.min.js", integrity: "sha384-q8i/X+965DzO0rT7abK41JStQIAqVgRVzpbzo5smXKp4YfRvH+8abtTE1Pi6jizo", crossorigin: "anonymous"}
    %script{src: "https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.14.3/umd/popper.min.js", integrity: "sha384-ZMP7rVo3mIykV+2+9J3UJ46jBk0WLaUAdn689aCwoqbBJiSnjAK/l8WvCWPIPm49", crossorigin: "anonymous"}
    %script{src: "https://stackpath.bootstrapcdn.com/bootstrap/4.1.1/js/bootstrap.min.js", integrity: "sha384-smHYKdLADwkXOn1EmN1qk/HfnUcbVRZyYmZ4qpPea6sjB/pTJ0euyQp0Mk8ck+5T", crossorigin: "anonymous"}
    = javascript_include_tag 'application', 'data-turbolinks-track' => 'reload'
    = javascript_include_tag controller_path, 'data-turbolinks-track' => 'reload'
CODE

  file '_navbar.html.haml', <<-CODE
.navbar.navbar-expand-lg.navbar-light.bg-light
  = link_to content_for?(:title) ? yield(:title) : (ENV['APP_TITLE'] || Rails.application.class.parent_name), root_path, class: "navbar-brand"

  %button.navbar-toggler(type="button" data-toggle="collapse" data-target="#NavMain" aria-controls="NavMain" aria-expanded="false" aria-label="Toggle navigation")
    %span.navbar-toggler-icon

  .collapse.navbar-collapse#NavMain
    - if user_signed_in?
      %ul.navbar-nav.flex-grow-1
        %li{ active_if('welcome', 'index') }
          = link_to t('menu.active', default: 'Active'),  root_path, class: 'nav-link'
        %li{ active_if('test', 'index') }
          = link_to t('menu.inactive', default: 'Inactive'),  root_path, class: 'nav-link'
      %ul.navbar-nav
        %li.nav-item
          .navbar-text v:0.1.0
        %li.nav-item.dropdown
          %a.nav-link.dropdown-toggle#navbarDropdown(href='#' role="button" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false")
            \#{current_user.email}
          .dropdown-menu(aria-labelledby="navbarDropdown")
            = link_to t('menu.logout', default: 'Logout'),  destroy_user_session_path, method: :delete, class: 'dropdown-item'
    - else
      %ul.navbar-nav.flex-grow-1
        %li.nav-item
      %ul.navbar-nav
        %li.nav-item
          .navbar-text v:0.1.0
        %li{ active_if('devise/sessions') }
          = link_to t('menu.login', default: 'Login'),  new_user_session_path, class: 'nav-link'
CODE

  file '_messages.html.haml', <<-CODE
- flash.each do |type, message|
  - if message.is_a?(String)
    .alert.alert-dismissible{class: "alert-\#{ type.to_sym == :notice ? 'info' : 'success' }" }
      %button.close{ data: { dismiss: "alert" } }
        %span{:'aria-hidden' => true} &times;
        %span.sr-only Close
      = message
  - elsif message.is_a?(ActiveModel::Errors)
    .alert.alert-dismissible.alert-danger
      %button.close{ data: { dismiss: "alert" } }
        %span{:'aria-hidden' => true} &times;
        %span.sr-only Close
      - message.full_messages.each do |msg|
        %p= msg
CODE

  file '_bottom.html.haml', ""

end

inside('app/assets/javascripts') do
  file 'application.coffee', <<-CODE
//= require rails-ujs
//= require activestorage
# require jquery */
# require bootstrap.min */
//= require fie
CODE
end


inside('app/assets/stylesheets') do
  file 'application.scss', <<-CODE
  $screen-md:       850px !default;
  $screen-md-min:   $screen-md !default;
  $screen-sm:       630px !default;
  $screen-sm-min:   $screen-sm !default;

  /* @import           "bootstrap.min.css"; */

  body {
    padding-top:    20px;
    padding-bottom: 20px;
  }

  .inline           { display: inline-block; }

  .navbar {
    margin-bottom:  20px;
  }

  .form-actions {
    padding-top: 20px;
  }

  .badge-error {
    background-color: #b94a48;
  }
  .badge-warning {
    background-color: #f89406;
  }
  .badge-success {
    background-color: #468847;
  }
  .badge-info {
    background-color: #3a87ad;
  }
  .badge-inverse {
    background-color: #333333;
  }

 a.navbar-brand.active {
   color: #f89406;
 }

 .bordered {
   border: 1px solid lightgray;
   border-radius: 3px;
   margin: -1px;
 }

 .result {
   margin-top: 1em;
   margin-bottom: 1em;
   min-height: 2.5em;
   padding: 0.5em;
 }

 .help-block {
   padding-left: 1em;
 }
CODE

end

run 'rm -f app/views/layouts/application.html.erb'
run 'rm -f app/assets/stylesheets/application.css'
run 'rm -f app/assets/javascripts/application.js'

generate('controller', 'welcome', 'index')
generate('devise:install')
generate('devise:views')
generate('assets devise/confirmations')
generate('assets devise/passwords')
generate('assets devise/registrations')
generate('assets devise/sessions')
generate('assets devise/unlocks')
generate('devise', 'User')

route "root to: 'welcome#index'"
run 'bin/rails db:migrate'

file '.versions.conf', <<-CODE
#ruby=
#ruby-gemset=
CODE

file 'config/cable.yml', <<-CODE

redis: &redis
  adapter: redis
  url: <%= ENV.fetch("REDIS_URL") { "redis://localhost:6379/1" } %>

development:
  <<: *redis
  channel_prefix: #{app_const_base.underscore}_development

test:
  <<: *redis
  channel_prefix: #{app_const_base.underscore}_test

production:
  <<: *redis
  channel_prefix: #{app_const_base.underscore}_production

CODE
end
