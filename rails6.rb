gem 'jquery-rails'                    # Provides jQuery and the jQuery-ujs driver
gem 'bootstrap-sass'                  # Sass-powered version of Bootstrap
gem 'haml'                            # HTML Abstraction Markup Language
gem 'simple_form'                     # Forms made easy for Rails!
gem 'responders'                      # A set of responders modules to dry up
gem 'settingson'                      # Settings management

gem 'http'                            # A fast Ruby HTTP client
gem 'faker'                           # A library for generating fake data

gem 'devise'                          # Flexible authentication solution for Rails with Warden
gem 'libv8'                           # V8 JavaScript engine
gem 'therubyracer'                    # Embed the V8 JavaScript interpreter into Ruby

gem_group :development do
  gem 'haml-rails'                    # haml intergration for Rails
  gem 'better_errors'                 # Better errors handler
  gem 'binding_of_caller'             # For better_errors
  gem 'brakeman'                      # Security scanner. Usage: brakeman [-o file.html]
  gem 'bullet'                        # Query optimization # TODO need to configure
  gem 'annotate'                      # Annotate ActiveRecord models. Usage: annotate
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
end

run "sed -i -e '/webpacker/d' Gemfile"

after_bundle do

environment "
    config.assets.compile     = true
    config.assets.check_precompiled_asset = false

    config.generators do |g|
      g.test_framework :rspec, :views => false, :fixture => true
      g.fixture_replacement :factory_bot, :dir => 'spec/factories'
      g.template_engine :haml
      g.view_specs false
      g.helper_specs false
    end
"

inside do
  generate('simple_form:install', '--bootstrap')
  generate('settingson', 'Settings')
  generate('rspec:install')
end

initializer 'web_console_whitelist.rb', <<-CODE
Rails.application.configure do
  config.web_console.whitelisted_ips = ['192.168.1.0/24']
  config.web_console.permissions = '192.168.1.0/24'
end
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
  #   section == controller.class.module_parent_name.to_s.underscore
  # end

end

CODE
end

inside('app/views/layouts') do
  file 'application.html.haml', <<-CODE
!!!
%html{lang: 'en'}
  %head
    %title= content_for?(:title) ? yield(:title) : (ENV['APP_TITLE'] || Rails.application.class.module_parent_name.underscore)
    %meta{charset: 'utf-8'}
    %meta{content: 'IE=edge', 'http-equiv' => 'X-UA-Compatible'}
    %meta{content: 'width=device-width, initial-scale=1, shrink-to-fit=no', name: 'viewport'}
    %link{rel: "stylesheet", href: "https://stackpath.bootstrapcdn.com/bootstrap/4.1.1/css/bootstrap.min.css", integrity: "sha384-WskhaSGFgHYWDcbwN70/dfYBj47jz9qbsMId/iRN3ewGhXQFZCSftd1LZCfmhktB", crossorigin: "anonymous"}
    = stylesheet_link_tag 'application', media: 'all', 'data-turbolinks-track' => true
    - unless controller.class.module_parent == Devise
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
      - if controller.class.module_parent == Devise
        = yield
    %script{src: "https://code.jquery.com/jquery-3.3.1.slim.min.js", integrity: "sha384-q8i/X+965DzO0rT7abK41JStQIAqVgRVzpbzo5smXKp4YfRvH+8abtTE1Pi6jizo", crossorigin: "anonymous"}
    %script{src: "https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.14.3/umd/popper.min.js", integrity: "sha384-ZMP7rVo3mIykV+2+9J3UJ46jBk0WLaUAdn689aCwoqbBJiSnjAK/l8WvCWPIPm49", crossorigin: "anonymous"}
    %script{src: "https://stackpath.bootstrapcdn.com/bootstrap/4.1.1/js/bootstrap.min.js", integrity: "sha384-smHYKdLADwkXOn1EmN1qk/HfnUcbVRZyYmZ4qpPea6sjB/pTJ0euyQp0Mk8ck+5T", crossorigin: "anonymous"}
    = javascript_include_tag 'application', 'data-turbolinks-track' => 'reload'
    - unless controller.class.module_parent == Devise
      = javascript_include_tag controller_path, 'data-turbolinks-track' => 'reload'
CODE

  file '_navbar.html.haml', <<-CODE
.navbar.navbar-expand-lg.navbar-light.bg-light
  = link_to content_for?(:title) ? yield(:title) : (ENV['APP_TITLE'] || Rails.application.class.module_parent_name.underscore), root_path, class: "navbar-brand"

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
  file 'application.js', <<-CODE
//= require rails-ujs
//= require activestorage
//= require jquery
//= require bootstrap.min
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

generate('devise:install')
generate('devise:views')
generate('assets devise/confirmations')
generate('assets devise/passwords')
generate('assets devise/registrations')
generate('assets devise/sessions')
generate('assets devise/unlocks')
generate('devise', 'User')
generate('controller', 'Welcome', 'index')

inside('app/assets/javascripts') do
  file'welcome.js', <<-CODE
CODE
end

route "root to: 'welcome#index'"
run 'bin/rails db:migrate'

file '.versions.conf', <<-CODE
#ruby=
#ruby-gemset=
CODE

end

