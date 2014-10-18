require File.expand_path('../boot', __FILE__)

# Pick the frameworks you want:
# require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "sprockets/railtie"
require "rails/test_unit/railtie"
require "mongoid/railtie"

# require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default, Rails.env)

module TimeChatNet
  class Application < Rails::Application
    ERROR_LOGIN                 = 0
    SUCCESS_LOGIN               = 1
    SUCCESS_LOGOUT              = 6
    SUCCESS_QUERY               = 7
    NOT_LOGIN                   = 2
    ERROR_REGISTERED            = 3
    ERROR_QUERY                 = 4
    ERROR_INVALID_FIELD         = 5
    LOGINED                     = 8
    API_DEFAULT                 = 9
    SUCCESS_REGISTERED          = 10
    ERROR_FIELD_EXIST           = 11
    ERROR_PASSWORD_NOT_MATCH    = 12
    ERROR_RECORD_NOT_EXIST      = 13
    ERROR_CHANGE_PASSWORD       = 14
    SUCCESS_CHANGE_PASSWORD     = 15
    SUCCESS_REGISTERED_PLEASE_CONFIRM_YOUR_EMAIL = 16
    SUCCESS_CONFIRM             = 17
    ERROR_CHANGE_EMAIL          = 18
    COMMENT_NOT_FIND            = 19
    ACCESS_DENIED               = 20
    ERROR_FIELD_NOT_SET         = 21
    ERROR_DONT_SUPPORT          = 22
    ERROR_CUSTOM                = 23
    SUCCESS_CUSTOM              = 24
    NOTICE_CUSTOM               = 25
    ERROR_SEND_MAIL             = 26

    #profile change value

    SUCCESS_CHANGE_USER_NAME    = 27
    SUCCESS_CHANGE_EMAIL        = 28
    

    # user invited status
    USER_REGISTERED         = 201
    USER_UNREGISTERED       = 202
    USER_INVITED_IN_SYSTEM  = 203
    USER_INVITED_IN_FRIEND  = 204
    USER_ALREADY_FRIEND     = 205

    # friends status
    FRIEND_ACCEPT           = 301
    FRIEND_INVITED          = 302
    FRIEND_DECLINE          = 303
    FRIEND_IGNORE           = 304
    FRIEND_DISABLE_FRIEND   = 305

    # type notification
    NOTIFICATION_NEW_COMMENT                    = 401
    NOTIFICATION_INVITE_IN_FRIEND               = 402
    NOTIFICATION_ACCEPT_FRIEND                  = 403
    NOTIFICATION_REGISTERED_FRIEND              = 404
    NOTIFICATION_REMOVED_FRIEND                 = 405
    NOTIFICATION_DECLINE_FRIEND                 = 406
    NOTIFICATION_FRIEND_ADDED_NEW_PHOTO         = 407
    NOTIFICATION_FRIEND_ADDED_NEW_VIDEO         = 408
    NOTIFICATION_FRIEND_COMMENTED_YOUR_PHOTO    = 409
    NOTIFICATION_FRIEND_COMMENTED_YOUR_VIDEO    = 410
    NOTIFICATION_FRIEND_LIKE_YOUR_PHOTO         = 411
    NOTIFICATION_FRIEND_LIKE_YOUR_VIDEO         = 412
    NOTIFICATION_SETTINGS_ENABLE                = 413
    NOTIFICATION_SETTINGS_DISABLE               = 414
    NOTIFICATION_ADDED_NEW_USER                 = 415
    NOTIFICATION_ACCESS_MEDIA_USER              = 416

    # role
    NOT_CONFIRM_USER = 501
    CONFIRM_USER = 502

   # media
   ERROR_MEDIA_TYPE_FILE = 601
   SUCCESS_UPLOADED = 602
   MEDIA_NOT_FOUND = 603

   # messages
   DEBUG = "User unregistered system"
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
    config.paths.add "app/api", :glob => "**/*.rb"
    config.autoload_paths += Dir["#{Rails.root}/app/api/*"]
    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de
    config.before_configuration do
      env_file = File.join(Rails.root, 'config', 'local_env.yml')
      YAML.load(File.open(env_file)).each do |key, value|
        ENV[key.to_s] = value
      end if File.exists?(env_file)
    end
  end
end
