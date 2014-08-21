source 'https://rubygems.org'
ruby '2.1.1'
gem 'rails', '4.1.0'

gem 'jquery-rails'
gem 'turbolinks'
gem 'jbuilder', '~> 1.2'

gem 'devise'
# gem 'devise_invitable'

gem 'omniauth-facebook'

gem 'rolify'
gem 'cancan'

gem 'simple_form'
gem 'thin'

gem 'haml-rails'
gem 'haml2slim'
gem 'html2haml'
gem 'parsley-rails'

gem 'bootstrap-sass', '~> 2.3.2.2'
gem 'bootstrap-datepicker-rails'
gem 'bootstrap_form'
#gem 'will_paginate-bootstrap'
gem 'will_paginate_mongoid'

# gem 'lazy_high_charts'
gem 'tinymce-rails'
# gem 'tinymce-rails-imageupload', '~> 4.0.0.beta'

gem 'mongoid', git: 'https://github.com/mongoid/mongoid.git'
gem 'delayed_job_mongoid', :github => 'shkbahmad/delayed_job_mongoid'
gem 'bson_ext'

gem 'carrierwave', :git => "git://github.com/jnicklas/carrierwave.git"
gem 'carrierwave-mongoid', :require => 'carrierwave/mongoid'
gem 'mini_magick'

gem 'aws-sdk'
gem 'fog'
gem 'unf'

gem 'sanitize'

# gem 'stripe'
# gem 'stripe-rails'
# gem 'stripe_event'
# gem 'redis'
# gem 'resque', '~> 2.0.0.pre.1', github: "resque/resque"

gem 'pushmeup'

# gem 'geocoder'

#Use Grape for API
gem 'grape'


#facebook message
gem 'xmpp4r_facebook'
gem 'fb_graph'

# gem 'mailboxer'
gem 'mandrill_mailer'

gem 'simple_captcha', :git => 'git://github.com/Azdaroth/simple-captcha.git', :branch => 'rails-4' 
#gem 'wolcanus-simple_captcha', :require => 'simple_captcha', :git => 'git://github.com/v1rtual/simple-captcha.git', :branch => 'rails-4' 

group :assets do
  gem 'sass-rails', '~> 4.0.0'
  gem 'uglifier', '>= 1.3.0'
  gem 'coffee-rails', '~> 4.0.0'
  gem 'therubyracer', :platforms => :ruby

  gem "less-rails"
  gem 'twitter-bootstrap-rails'
end
gem 'binding_of_caller'
group :development do
  gem 'better_errors'  
  gem 'capistrano', '~> 3.0.1'
  gem 'capistrano-bundler'
  gem 'capistrano-rails', '~> 1.1.0'
  gem 'capistrano-rails-console'
  gem 'capistrano-rvm', '~> 0.1.1'
  gem 'hub', :require=>nil
  gem 'quiet_assets'
  gem 'rails_layout'
  gem 'debugger'
  gem 'letter_opener'
end
group :development, :test do
  gem 'factory_girl_rails'
  gem 'pry-rails'
  gem 'pry-rescue'
  gem 'rspec-rails'
end
group :test do
  gem 'capybara'
  gem 'database_cleaner', '1.0.1'
  gem 'email_spec'
  gem 'mongoid-rspec', '>= 1.10.0'
end
group :production, :heroku do
  gem 'rails_12factor'
end
