class Comment
  include Mongoid::Document
  include Mongoid::Timestamps

  field :comment, type: String
  
  belongs_to :medium
  belongs_to :user

  def api_detail
    {
      id:id.to_s,
      avatar:user.avatar_url,
      created_time:created_at.strftime("%Y-%m-%d %H:%M:%S"),
      media_id:medium.id.to_s,
      message:comment,
      role:TimeChatNet::Application::CONFIRM_USER,
      time_zone:user.time_zone,
      user_id:user.id.to_s,
      user_time:Time.now+user.time_zone.to_i,
      user_name:user.name
    }
  end
end
