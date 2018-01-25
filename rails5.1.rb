run 'echo > Gemfile'

add_source 'https://rubygems.org'

gem 'rails', '~> 5.1.4'                   # Ruby on Rails is a full-stack web framework
gem 'sqlite3'                             # Use sqlite3 as the database for Active Record
gem 'puma', '~> 3.7'                      # Application server
gem 'sass-rails', '~> 5.0'                # Use SCSS for stylesheets
gem 'uglifier', '>= 1.3.0'                # Compressor for JavaScript assets
gem 'coffee-rails', '~> 4.2'              # For .coffee assets and views
gem 'turbolinks', '~> 5'                  # Makes navigating your web application faster
gem 'jbuilder', '~> 2.5'                  # Build JSON APIs with ease
# gem 'redis', '~> 3.0'                   # Redis adapter to run Action Cable in production
# gem 'bcrypt', '~> 3.1.7'                # ActiveModel has_secure_password

gem 'jquery-rails'                        # A gem to automate using jQuery with Rails
gem 'bootstrap-sass'                      # Sass-powered version of Bootstrap
gem 'haml-rails'                          # Integration for HAML
gem 'simple_form'                         # Forms made easy for Rails!
gem 'responders'                          # A set of responders modules to dry up
gem 'devise'                              # Flexible authentication solution for Rails with Warden
gem 'settingson'                          # Settings management
gem 'faker'                               # A library for generating fake data
gem 'rails_semantic_logger'               # A feature rich logging framework
# gem 'devise'                              # Flexible authentication solution for Rails with Warden
# gem 'http'                                # A fast Ruby HTTP client
# gem 'haml_coffee_assets'                  # Compile Haml CoffeeScript templates in the Rails asset pipeline

gem_group :development, :test do
  # gem 'byebug'                            # Byebug is a Ruby debugger
  # gem 'capybara', '~> 2.13'               # Acceptance test framework for web applications
  # gem 'selenium-webdriver'                # WebDriver is a tool for writing automated tests
end

gem_group :development do
  gem 'web-console', '>= 3.3.0'           # Rails Console on the Browser
  gem 'listen', '>= 3.0.5', '< 3.2'       # Listens to file modifications
  gem 'spring'                            # Preloads your application
  gem 'spring-watcher-listen', '~> 2.0.0' # Makes spring watch files using the listen gem
  gem 'spring-commands-rspec'             # Implements the rspec command for Spring
  gem 'annotate'                          # Annotate ActiveRecord models. Usage: annotate
  gem 'brakeman'                          # Security scanner. Usage: brakeman [-o file.html]
  gem 'rack-mini-profiler'                # Rails profiler
  # gem 'capistrano-rails'                  # Use Capistrano for deployment
  # gem 'railroady'                         # Class diagram generator. Usage: rake diagram:all
  # gem 'better_errors'                     # Better errors handler
  # gem 'binding_of_caller'                 # For better_errors
  # gem 'meta_request'                      # For RailsPanel (chrome extention)
  # gem 'bullet'                            # Query optimization # TODO need to configure
end

gem_group :test do
  gem 'rspec-rails'                       # Test suite
  gem 'factory_bot_rails'                # Fixtures replacement
  gem 'database_cleaner'                  # Helper gem for rspec
  gem 'simplecov', require: false         # Code coverage
  gem 'webmock', require: false           # Library for stubbing HTTP requests
end

run 'bundle install'

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

Rails.application.config.assets.precompile += %w( welcome.* )
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

generate('simple_form:install', '--bootstrap')
generate('devise:install')
generate('devise', 'User')
generate('settingson', 'Settings')
generate('rspec:install')
generate('controller', 'welcome', 'index')

route "root to: 'welcome#index'"

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
    %title= content_for?(:title) ? yield(:title) : Rails.application.class.parent_name
    %meta{charset: 'utf-8'}
    %meta{content: 'IE=edge', 'http-equiv' => 'X-UA-Compatible'}
    %meta{content: 'width=device-width, initial-scale=1', :name => 'viewport'}
    = csrf_meta_tags
    = stylesheet_link_tag 'application', media: 'all', 'data-turbolinks-track' => true
    = stylesheet_link_tag controller_path, media: 'all', 'data-turbolinks-track' => true
    = javascript_include_tag 'application', 'data-turbolinks-track' => false
    = javascript_include_tag controller_path, 'data-turbolinks-track' => false

  %body
    .container-fluid
      = render 'layouts/navbar'
    .container-fluid
      = yield :header
    .container-fluid
      .row
        .col-md-8.col-md-offset-2
          = render 'layouts/messages'
    .container-fluid
      .row
        .col-md-10.col-md-offset-1
          = yield
    .container-fluid
      = render 'layouts/bottom'
CODE

  file '_navbar.html.haml', <<-CODE
.navbar.navbar-default
  .container-fluid
    .navbar-header
      %button.navbar-toggle.collapsed{"data-target" => ".navbar-collapse", "data-toggle" => "collapse", :type => "button"}
        %span.sr-only Toggle navigation
        %span.icon-bar
        %span.icon-bar
        %span.icon-bar
      = link_to content_for?(:title) ? yield(:title) : Rails.application.class.parent_name, root_path, class: "navbar-brand"
    .collapse.navbar-collapse
      %ul.nav.navbar-nav
        %li{ active_if('welcome') }
          = link_to t('welcome', default: 'Welcome'),  welcome_index_path
      %ul.nav.navbar-nav.navbar-right
        %p.navbar-text v:0.0.1
        - if current_user and current_user.email
          = link_to destroy_user_session_path, method: :delete, class: 'btn btn-default navbar-btn' do
            %span.glyphicon.glyphicon-off
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
#= require jquery
#= require jquery_ujs
#= require bootstrap
#= require turbolinks
CODE
end


inside('app/assets/stylesheets') do
  file 'application.scss', <<-CODE
$screen-md:       850px !default;
$screen-md-min:   $screen-md !default;
$screen-sm:       630px !default;
$screen-sm-min:   $screen-sm !default;

@import           "bootstrap-sprockets";
@import           "bootstrap";

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
CODE

end

run 'rm app/views/layouts/application.html.erb'
run 'rm app/assets/stylesheets/application.css'
run 'rm app/assets/javascripts/application.js'
run 'bin/rails db:migrate'
