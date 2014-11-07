class Comment
  include Mongoid::Document
  include Mongoid::Timestamps
  mount_uploader :audio_comment, MediaUploader

  field :comment,       type: String
  
  field :audio_comment, type: String

  belongs_to :medium
  belongs_to :user
  
  after_create :send_notification

  def message
    if comment.present?
      comment
    else
      audio_comment.url
    end
  end

  def api_detail
    {
      id:id.to_s,
      comment_type: comment.present? ? 1 : 0,
      avatar:user.avatar_url,
      created_time:created_at.strftime("%Y-%m-%d %H:%M:%S"),
      media_id:medium.id.to_s,
      message:message,
      role:TimeChatNet::Application::CONFIRM_USER,
      time_zone:user.time_zone,
      user_id:user.id.to_s,
      user_time:Time.now+user.time_zone.to_i,
      user_name:user.name
    }
  end

  def send_notification
    media_user = medium.user
    unless user == media_user
      media_user.send_notification_comment_your_media(user, medium) 
      media_user.send_push_notification("#{user.name} commented your media", user)
    end    
  end
end
