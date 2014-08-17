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
  

  belongs_to :friend, :class_name => "User"
  has_many :friends, :class_name => "User", :foreign_key=>"friend_id"
  has_many :devices, dependent: :destroy

  # belongs_to :admin, :class_name => "User"
  # has_many :managers, :class_name => "User", :foreign_key=>"admin_id", :dependent => :destroy
  

  validates_presence_of :role
  
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

  def find_by_auth_token token
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
