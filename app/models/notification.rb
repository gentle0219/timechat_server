class Notification
  include Mongoid::Document
  include Mongoid::Timestamps

  TYPE = %w[invite decline accept ignore remove]
  
  field :message,           type: String
  
  field :data,              type: String
  field :type,              type: String

  field :is_read,           type: Boolean, default: false


  belongs_to :user
  scope :unread_notifications, ->{where(is_read:false)}

  def api_detail  
    if Notification::TYPE.include? type
      friend = User.where(id:data).first
      info = {
              id:id.to_s,
              date: created_at.strftime("%Y-%m-%d %H:%M:%S"),
              additional:1,
              debug: "#{friend.name} to add you in his friends",
              friend_time: friend.created_at,
              from: friend.name,
              fromEmail: friend.email,
              status: 1,
              status_info: "Sent notification",
              type: TimeChatNet::Application::NOTIFICATION_INVITE_IN_FRIEND,
              user_id: friend.id.to_s,
              user_time: user.created_at
            }
    end    
  end

  def read!
    notification = self
    notification.update_attribute(:is_read, true)
  end
end
