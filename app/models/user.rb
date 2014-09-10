class User
  include Mongoid::Document
  include Mongoid::Timestamps
  
  ROLES = ['user', 'admin']
  SOCIAL_TYPES = %w[email facebook twitter google]
  mount_uploader :avatar, AvatarUploader
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable #, :token_authenticatable
         
  ## Database authenticatable
  field :email,                     :type => String, :default => ""
  field :name,                      :type => String, :default => ""
  
  field :encrypted_password,        :type => String, :default => ""  
  field :country_code,              :type => String
  field :confirmed_value,           :type => String, :default => ""

  ## Recoverable
  field :reset_password_token,      :type => String
  field :reset_password_sent_at,    :type => Time

  ## Rememberable
  field :remember_created_at,       :type => Time

  ## Trackable
  field :sign_in_count,             :type => Integer, :default => 0
  field :current_sign_in_at,        :type => Time
  field :last_sign_in_at,           :type => Time
  field :current_sign_in_ip,        :type => String
  field :last_sign_in_ip,           :type => String

  ## Confirmable
  # field :confirmation_token,      :type => String
  # field :confirmed_at,            :type => Time
  # field :confirmation_sent_at,    :type => Time
  # field :unconfirmed_email,       :type => String # Only if using reconfirmable

  ## Lockable
  # field :failed_attempts,         :type => Integer, :default => 0 # Only if lock strategy is :failed_attempts
  # field :unlock_token,            :type => String # Only if unlock strategy is :email or :both
  # field :locked_at,               :type => Time

  field :role,                      :type => String,    :default => User::ROLES[0]
  field :avatar,                    :type => String

  field :social_type,               :type => String,    :default => User::SOCIAL_TYPES[0]
  field :social_id,                 :type => String,    :default => ''

  field :time_zone,                 :type => String,    :default => '0'

  field :friend_ids,                :type => String,    :default => ''
  field :invited_friend_ids,        :type => String,    :default => ''
  field :ignored_friend_ids,        :type => String,    :default => ''

  # setting options
  field :auto_accept_friend,        :type => Boolean,   :default => false
  field :auto_notify_friend,        :type => Boolean,   :default => false

  field :push_enable,               :type => Boolean,   default: true
  field :sound_enable,              :type => Boolean,   default: true


  field :authentication_token,      :type => String  
  before_save :ensure_authentication_token
  



  # belongs_to :friend, :class_name => "User"
  # has_many :friends, :class_name => "User", :foreign_key=>"friend_id"

  # field :like_media_ids,                  :type => String,    :default =>''
  
  has_many :devices,                dependent: :destroy
  has_many :notifications,          dependent: :destroy
  
  has_many :medias, class_name: 'Medium',                 dependent: :destroy
  has_many :comments,               dependent: :destroy
  has_many :likes
  


  validates_uniqueness_of :name
  validates_presence_of :role
  
  def unread_notifications
    notifications.unread_notifications
  end
  def friends
    friends = User.in(id:friend_ids.split(","))    
  end

  # def add_like_media(media)
  #   user = self
  #   lm_ids = like_medias.split(",")
  #   lm_ids << media.id.to_s
  #   user.update_attributes(like_media_ids:lm_ids.uniq.join(","))
  #   friend = like.user
  #   friend.send_notification_like_your_photo(user, media.media_type) unless user == friend
  # end

  # def like_medias
  #   Medium.in(id:like_media_ids.split(","))
  # end

  def device_id
    devices.first.dev_id if devices.present?
  end

  def is_admin?
    self.role == User::ROLES[1]
  end

  def role_of_number
    User::MANAGER_ROLES.index(role)
  end

  def is_user?
    self.role == User::ROLES[0]
  end
 
  def self.search(search)
    if search.present?
      self.or({ :email => /.*#{search}*./ }, { :name => /.*#{search}*./ })
    else
      self
    end
  end  

  def ensure_authentication_token
    self.authentication_token ||= generate_authentication_token
  end

  def send_invite_friend_notification(friend)
    self.notifications.create(message:"#{friend.name} wants to add you in his friends", data:friend.id.to_s, type:Notification::TYPE[0], status:TimeChatNet::Application::NOTIFICATION_INVITE_IN_FRIEND)
    count = self.notifications.unread_notifications.count
    self.send_push("#{friend.name} wants to add you in his friends", count)
  end

  def send_accept_friend_notification(accepted_user)
    user                      = self
    invited_f_ids             = invited_friend_ids.split(",")
    invited_f_ids.delete(accepted_user.id.to_s)
    user.invited_friend_ids   = invited_f_ids.join(",")
    user.save
    if accepted_user.auto_accept_friend
      user.notifications.create(message:"#{accepted_user.name} accepted your invitation to friends automatically", data:accepted_user.id.to_s, type:Notification::TYPE[2], status:TimeChatNet::Application::NOTIFICATION_ACCEPT_FRIEND)
    else
      user.notifications.create(message:"#{accepted_user.name} accepted your invitation to friends", data:accepted_user.id.to_s, type:Notification::TYPE[2], status:TimeChatNet::Application::NOTIFICATION_ACCEPT_FRIEND)
    end
    count = user.notifications.unread_notifications.count
    user.send_push("#{friend.name} wants to add you in his friends", count)
  end

  def send_decline_friend_notification(declined_user)
    user                      = self
    f_ids                     = friend_ids.split(",")
    f_ids.delete(declined_user.id.to_s)

    invited_f_ids             = invited_friend_ids.split(",")
    invited_f_ids.delete(declined_user.id.to_s)

    user.friend_ids           = f_ids.uniq.join(",")
    user.invited_friend_ids   = invited_f_ids.uniq.join(",")
    user.save

    user.notifications.create(message:"#{declined_user.name} declined your invitiation to friends", data:declined_user.id.to_s, type:Notification::TYPE[1], status:TimeChatNet::Application::NOTIFICATION_DECLINE_FRIEND)
    count = user.notifications.unread_notifications.count
    user.send_push("#{friend.name} wants to add you in his friends", count)
  end

  def send_ignore_friend_notification(ignored_user)
    #self.notifications.create(message:"#{ignored_user.name} Ignored Friend", data:ignored_user.id.to_s, type:Notification::TYPE[2], status:TimeChatNet::Application::FRIEND_IGNORE)
  end

  def send_remove_ignore_friend_notification(ignored_user)
    #self.notifications.create(message:"#{ignored_user.name} has deleted you from friends", data:ignored_user.id.to_s, type:Notification::TYPE[3], status:TimeChatNet::Application::FRIEND_DISABLE_FRIEND)
  end
  
  def send_removed_friend_notification(removed_user)
    user                      = self
    f_ids                     = friend_ids.split(",")
    f_ids.delete(removed_user.id.to_s)
    user.friend_ids           = f_ids.uniq.join(",")   

    ignore_f_ids              = removed_user.ignored_friend_ids.split(",")
    ignore_f_ids.delete(user.id.to_s)
    removed_user.ignored_friend_ids   = ignore_f_ids.uniq.join(",")
    
    user.save
    removed_user.save
    user.notifications.create(message:"#{removed_user.name} removed you from friends", data:removed_user.id.to_s, type:Notification::TYPE[4], status:TimeChatNet::Application::NOTIFICATION_REMOVED_FRIEND)
  end

  def send_photo_shared_friend_notification(share_user, media)
    user = self
    user.notifications.create(message:"#{share_user.name} shared new photo", data:share_user.id.to_s, media_id:media.id.to_s, type:Notification::TYPE[5], status:TimeChatNet::Application::NOTIFICATION_FRIEND_ADDED_NEW_PHOTO)
  end

  def send_video_shared_friend_notification(share_user, media)
    user = self
    user.notifications.create(message:"#{share_user.name} shared new video", data:share_user.id.to_s, media_id:media.id.to_s, type:Notification::TYPE[5], status:TimeChatNet::Application::NOTIFICATION_FRIEND_ADDED_NEW_VIDEO)
  end
  
  def send_notification_add_new_comment(comment_user)
    user = self
    user.notifications.create(message:"You have received an comment from #{comment_user.name}", data:comment_user.id.to_s, type:Notification::TYPE[6], status:TimeChatNet::Application::NOTIFICATION_NEW_COMMENT)
  end

  def send_notification_like_your_photo(liked_user, type)
    user = self    
    status = type == '1' ? TimeChatNet::Application::NOTIFICATION_FRIEND_LIKE_YOUR_PHOTO : TimeChatNet::Application::NOTIFICATION_FRIEND_COMMENTED_YOUR_VIDEO
    user.notifications.create(message:"Added new like", data:liked_user.id.to_s, type:Notification::TYPE[7], status:status)
  end

  def send_added_new_user_notification(new_user)
    user = self
    user.notifications.create(message:"#{new_user.name} has joined into TimeChat", data:new_user.id.to_s, type:Notification::TYPE[9], status:TimeChatNet::Application::NOTIFICATION_REGISTERED_FRIEND)
  end

  def is_friend(friend)
    return true if friend.id == self.id
    friend_ids.split(",").include?(friend.id.to_s) and !invited_friend_ids.split(",").include?(friend.id.to_s) # and !ignored_friend_ids.split(",").include?(friend.id.to_s)
  end  

  def is_invited_friend(friend)
    invited_friend_ids.split(",").include?(friend.id.to_s)
  end

  def is_block(friend)
    if ignored_friend_ids.split(",").include? friend.id.to_s
      TimeChatNet::Application::FRIEND_IGNORE
    else
      TimeChatNet::Application::FRIEND_DISABLE_FRIEND
    end
  end

  def time
    server_time_zone_offset = Time.now.gmt_offset
    offset = server_time_zone_offset / 60 / 60
    Time.now + (time_zone.to_i-offset).hours
  end
  def add_friend(friend)    
    user                      = self
    f_ids                     = friend_ids.split(",") << friend.id.to_s
    invited_f_ids             = invited_friend_ids.split(",") << friend.id.to_s

    user.friend_ids           = f_ids.uniq.join(",")
    user.invited_friend_ids   = invited_f_ids.uniq.join(",")
    if friend.auto_accept_friend
      friend.accept_friend(user)
    else      
      friend.send_invite_friend_notification(user)
    end
    user.save    
  end

  def accept_friend(friend)
    user                      = self
    f_ids                     = friend_ids.split(",") << friend.id.to_s    
    user.friend_ids           = f_ids.uniq.join(",")

    friend.send_accept_friend_notification(user)
    user.save
  end

  def decline_friend(friend)    
    friend.send_decline_friend_notification(self)
  end
  
  def ignore_friend(friend)
    user                      = self
    ignore_f_ids              = ignored_friend_ids.split(",") << friend.id.to_s
    user.ignored_friend_ids   = ignore_f_ids.uniq.join(",")
    user.save
    friend.send_ignore_friend_notification(user)
  end

  def remove_ignore_friend(friend)
    user                      = self
    ignore_f_ids              = ignored_friend_ids.split(",")
    ignore_f_ids.delete(friend.id.to_s)     
    user.ignored_friend_ids   = ignore_f_ids.uniq.join(",")
    user.save
    friend.send_remove_ignore_friend_notification(user)
  end

  def remove_friend(friend)
    user                      = self
    f_ids                     = friend_ids.split(",")
    f_ids.delete(friend.id.to_s)
    user.friend_ids           = f_ids.uniq.join(",")   

    ignore_f_ids              = ignored_friend_ids.split(",")
    ignore_f_ids.delete(friend.id.to_s)
    user.ignored_friend_ids   = ignore_f_ids.uniq.join(",")

    user.save
    friend.send_removed_friend_notification(user)
  end

  def friend_api_detail(user)
    friend = self
    {id:friend.id.to_s,username:friend.name,avatar:friend.avatar.url,email:friend.email,code: TimeChatNet::Application::USER_REGISTERED, debug: "User registred in system", friend_status:user.is_block(friend), time_zone:friend.time_zone}
  end

  def avatar_url
    if avatar.present?
      avatar.url
    else
      ""
    end
  end

  def send_push(message, count)
    return false if self.devices.count < 0
    devices = self.devices
    devices.each do |device|
      if Rails.env.production?
        if device.platform == Device::DEVICE_PLATFORM[0]    # in case platform is ios
          APNS.send_notification(device.dev_id,alert:message, badge:count, sound: 'default')
        else
          destination = [device.dev_id]
          data = {:alert=>notification.message}
          GCM.send_notification(destination,data)
        end
      end
    end
  end

  def send_push_notification message
    return false if self.devices.count < 0
    devices = self.devices
    devices.each do |device|
      if Rails.env.production?
        if device.platform == Device::DEVICE_PLATFORM[0]    # in case platform is ios
          APNS.send_notification(device.dev_id,alert:message, badge:device.badge_count+1, sound: 'default')
        else
          destination = [device.dev_id]
          data = {:alert=>notification.message}
          GCM.send_notification(destination,data)
        end
      end
    end
  end

  def self.find_by_auth_token token
    User.where(authentication_token: token).first
  end

  def send_notification_to_all_users
    users = User.where(auto_notify_friend:true)
    users.each do |user|
      user.send_added_new_user_notification(self)
    end
  end


  private
  def generate_authentication_token
    loop do 
      token = Devise.friendly_token
      break token unless User.where(authentication_token:token).first
    end
  end  
end
