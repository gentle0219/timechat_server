class User
  include Mongoid::Document
  include Mongoid::Timestamps
  
  ROLES = ['user', 'admin']
  SOCIAL_TYPES = %w[email facebook twitter google]
  mount_uploader :avatar, AvatarUploader
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :token_authenticatable
         
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

  field :time_zone,                 :type => String

  field :authentication_token,      :type => String  
  before_save :ensure_authentication_token
  
  field :friend_ids,                :type => String,    :default => ''
  field :invited_friend_ids,        :type => String,    :default => ''
  field :delined_friend_ids,        :type => String,    :default => ''
  # belongs_to :friend, :class_name => "User"
  # has_many :friends, :class_name => "User", :foreign_key=>"friend_id"
  
  has_many :devices,                dependent: :destroy
  has_many :notifications,          dependent: :destroy
  

  validates_presence_of :role
  
  def unread_notifications
    notifications.unread_notifications
  end
  def friends
    User.in(id:friend_ids.split(","))
  end

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
    self.notifications.create(message:'Invited New Friend', data:friend.id.to_s, type:Notification::TYPE[0])
  end

  def send_accept_friend_notification(accepted_user)
    user                      = self
    invited_f_ids             = invited_friend_ids.split
    invited_f_ids             = invited_f_ids.delete(accepted_user.id.to_s)
    user.invited_friend_ids   = invited_f_ids.split(",")
    user.save
    user.notifications.create(message:'Accpted Friend', data:accepted_user.id.to_s, type:Notification::TYPE[2])
  end

  def send_decline_friend_notification(declined_user)
    user                      = self
    f_ids                     = friend_ids.split
    f_ids.delete(declined_user.id.to_s)

    invited_f_ids             = invited_friend_ids.split
    invited_f_ids.delete(declined_user.id.to_s)

    user.friend_ids           = f_ids.uniq.join(",")
    user.invited_friend_ids   = invited_friend_ids.uniq.join(",")
    user.save
    user.notifications.create(message:'Declined Friend', data:declined_user.id.to_s, type:Notification::TYPE[1])
  end

  def add_friend(friend)    
    user                      = self
    f_ids                     = friend_ids.split << friend.id.to_s
    invited_f_ids             = invited_friend_ids.split << friend.id.to_s

    user.friend_ids           = f_ids.uniq.join(",")
    user.invited_friend_ids   = invited_f_ids.split(",")

    friend.send_invite_friend_notification(user)
    user.save    
  end

  def accept_friend(friend)
    user                      = self
    f_ids                     = friend_ids.split << friend.id.to_s
    
    friend.send_accept_friend_notification(user)
    user.save
  end

  def decline_friend(friend)    
    friend.send_decline_friend_notification(self)    
  end

  def self.find_by_auth_token token
    User.where(authentication_token: token).first
  end

  private
  def generate_authentication_token
    loop do 
      token = Devise.friendly_token
      break token unless User.where(authentication_token:token).first
    end
  end  
end
