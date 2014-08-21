class Device
  include Mongoid::Document
  include Mongoid::Timestamps

  DEVICE_PLATFORM=%w[ios android]

  field :dev_id,          :type => String  
  field :platform,        :type => String,    default: 'ios'
  field :badge_count,     :type => Integer,   default: 0
  
  belongs_to :user  

  validates_uniqueness_of :dev_id, :scope => :user_id

  def self.create_by_device_id(dev_id, user)
    device = user.devices.where(dev_id:dev_id).first
    if device.present?
      device
    else
      user.devices.create(dev_id:dev_id, platform:'ios')
    end
  end
end
