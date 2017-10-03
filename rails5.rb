gem 'devise'                          # Flexible authentication solution for Rails with Warden
gem 'bootstrap-sass'                  # Sass-powered version of Bootstrap
gem 'haml'                            # HTML Abstraction Markup Language
gem 'haml-rails'                      # Integration for HAML
gem 'simple_form'                     # Forms made easy for Rails!
gem 'responders'                      # A set of responders modules to dry up
gem 'settingson'                      # Settings management
gem 'http'                            # A fast Ruby HTTP client
gem 'faker'                           # A library for generating fake data
gem 'rails_semantic_logger'           # A feature rich logging framework
gem 'backbone-on-rails'               # Easily setup and use backbone.js
gem 'marionette-rails'                # Backbone.Marionette library for use with Rails
gem 'haml_coffee_assets'              # Compile Haml CoffeeScript templates in the Rails asset pipeline

gem_group :development do
  gem 'railroady'                     # Class diagram generator. Usage: rake diagram:all
  gem 'better_errors'                 # Better errors handler
  gem 'binding_of_caller'             # For better_errors
  gem 'meta_request'                  # For RailsPanel (chrome extention)
  gem 'rack-mini-profiler'            # Rails profiler
  gem 'brakeman'                      # Security scanner. Usage: brakeman [-o file.html]
  gem 'bullet'                        # Query optimization # TODO need to configure
  gem 'annotate'                      # Annotate ActiveRecord models. Usage: annotate
  gem 'web-console'                   # Rails Console on the Browser
end

gem_group :development, :test do
  gem 'listen'
  gem 'spring-watcher-listen'
  gem 'spring-commands-rspec'         # Implements the rspec command for Spring
end

gem_group :production, :test do
  gem 'rails_12factor'      
end

gem_group :test do
  gem "rspec-rails"                   # Test suite
  gem 'factory_girl_rails'            # Fixtures replacement
  gem 'database_cleaner'              # Helper gem for rspec
  gem 'simplecov', require: false     # Code coverage
  gem 'webmock', require: false       # Library for stubbing HTTP requests
  gem 'capybara', require: false      # Acceptance test framework for web applications
end

run 'bundle install'

environment "
    config.assets.compile     = true

    config.generators do |g|
      g.test_framework :rspec, :views => false, :fixture => true
      g.fixture_replacement :factory_girl, :dir => 'spec/factories'
      g.template_engine :haml
      g.view_specs false
      g.helper_specs false
    end
"

initializer 'mini_profiler.rb', <<-CODE
if defined?(Rack::MiniProfiler)

  # Have Mini Profiler show up on the right
  Rack::MiniProfiler.config.position = 'right'

  # Have Mini Profiler start in hidden mode - display with short cut (defaulted to 'Alt+P')
  Rack::MiniProfiler.config.start_hidden = true

  Rack::MiniProfiler.config.toggle_shortcut = 'esc'
end
CODE

initializer 'assets.rb', <<-CODE
# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Add additional assets to the asset load path
# Rails.application.config.assets.paths << Emoji.images_path

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in app/assets folder are already added.
Rails.application.config.assets.precompile += %w( welcome.* tasks.* )
CODE

generate('simple_form:install', '--bootstrap')
generate('settingson', 'Settings')
generate('rspec:install')
generate('devise:install')
generate('devise', 'User')
generate('backbone:install')
generate('controller', 'welcome', 'index')
route "root to: 'welcome#index'"

inside('app/helpers') do
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
      - if current_user and current_user.email
        = simple_form_for Task.new, html: { class: 'navbar-form navbar-right task' }, remote: true, type: :json do |f|
          .form-group
            .input-group
              = f.input_field :title, class: 'form-control', autofocus: true
              .input-group-btn
                %button.btn.btn-primary.btn-send
                  %span.glyphicon.glyphicon-pencil
          .btn-group
            .btn-group
              %a.btn.btn-info.navbar-btn.dropdown-toggle(data-toggle="dropdown")
                = current_user.email[0..1].upcase
              %ul.dropdown-menu
                %li
                  %a options
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
#= require hamlcoffee
#= require underscore
#= require backbone
#= require backbone.marionette
#= require_tree ../templates
#= require_tree ./models
#= require_tree ./collections
#= require_tree ./views
#= require_tree ./routers

CODE
end


inside('app/assets/stylesheets') do
  file 'application.scss', <<-CODE
/*
 * This is a manifest file that'll be compiled into application.css, which will include all the files
 * listed below.
 *
 * Any CSS and SCSS file within this directory, lib/assets/stylesheets, vendor/assets/stylesheets,
 * or any plugin's vendor/assets/stylesheets directory can be referenced here using a relative path.
 *
 * You're free to add application-wide styles to this file and they'll appear at the bottom of the
 * compiled file so the styles you add here take precedence over styles defined in any other CSS/SCSS
 * files in this directory. Styles in this file should be added after the last require_* statement.
 * It is generally better to create a new file per style scope.
 *
 */

 /*
  * This is a manifest file that'll be compiled into application.css, which will include all the files
  * listed below.
  *
  * Any CSS and SCSS file within this directory, lib/assets/stylesheets, vendor/assets/stylesheets,
  * or any plugin's vendor/assets/stylesheets directory can be referenced here using a relative path.
  *
  * You're free to add application-wide styles to this file and they'll appear at the bottom of the
  * compiled file so the styles you add here take precedence over styles defined in any styles
  * defined in the other CSS/SCSS files in this directory. It is generally better to create a new
  * file per style scope.
  *
  */

  $screen-md:       850px !default;
  $screen-md-min:   $screen-md !default;
  $screen-sm:       630px !default;
  $screen-sm-min:   $screen-sm !default;

  @import           "bootstrap-sprockets";
  @import           "bootstrap";

  body {
   padding-top:    1em;
   padding-bottom: 1em;
  }

  .inline           { display: inline-block; }

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

  .navbar-btn, .form-control {
    height: inherit;
    margin: 0px;
  }

  #task_title {
    min-width: 100%;
    max-width: 100%;
    width: calc(100vw - 21em);
  }

CODE

end

run 'rm app/views/layouts/application.html.erb'
run 'rm app/assets/stylesheets/application.css'
run 'rm app/assets/javascripts/application.js'
run 'bin/rails db:migrate'
