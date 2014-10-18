class UserTempNotification
  include Mongoid::Document
  include Mongoid::Timestamps

  field :email,                   :type => String  
  belongs_to :user
  
  validates_presence_of :email, :user_id
  validates_uniqueness_of :email
end
