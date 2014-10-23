class Medium  
  include Mongoid::Document
  include Mongoid::Timestamps

  TYPE = %w[video photo]
  mount_uploader :file, MediaUploader
  mount_uploader :video_thumb, MediaUploader
  
  field :file,         		:type => String
  field :media_type,      :type => String, default: '1'
  field :shared_ids,      :type => String, default: ''
  field :video_thumb,     :type => String

  # field :liker_ids,       :type => String

  belongs_to :user
  has_many :comments, :order => 'created_at DESC', dependent: :destroy
  has_many :likes

  validates_presence_of :file, :user_id

  # default_scope -> {where(:created_at.gte => DateTime.new(Time.now.year,Time.now.month,Time.now.day))}

  def media_url
  	self.file.url if file.present?
  end
  def thumb_url
    self.video_thumb.url if video_thumb.present?
  end

  def share(friend)
    media = self
    ids = shared_ids.split(",")
    ids << friend.id.to_s
    media.update_attribute(:shared_ids,ids.uniq.join(","))
    friend.send_shared_friend_notification(user)
  end

  def share_friends(owner, friends)
    media = self
    friends.each do |f|
      ids = shared_ids.split(",")
      ids << f.id.to_s
      media.update_attribute(:shared_ids,ids.uniq.join(","))
      notif = f.notifications.where(media_id:media.id.to_s)
      
      unless notif.count > 0
        if media.media_type == '1'
          type = user.is_friend(f) ? TimeChatNet::Application::NOTIFICATION_FRIEND_ADDED_NEW_PHOTO : TimeChatNet::Application::NOTIFICATION_ACCESS_MEDIA_USER
          f.send_photo_shared_friend_notification(owner, media, type)
        else
          type = user.is_friend(f) ? TimeChatNet::Application::NOTIFICATION_FRIEND_ADDED_NEW_VIDEO : TimeChatNet::Application::NOTIFICATION_ACCESS_MEDIA_USER
          f.send_video_shared_friend_notification(owner, media, type)
        end
      end      
    end    
  end

  def unshare_friends(friends)
    media = self
    friends.each do |f|
      ids = shared_ids.split(",")
      ids.delete(f.id.to_s)      
    end
    media.update_attribute(:shared_ids,ids.uniq.join(","))
    # f.send_shared_friend_notification(user)
  end
  # def likers
  #   User.in(id:liker_ids.split(","))
  # end

  # def add_liker(liker)
  #   media = self
  #   l_ids = liker_ids.split(",")
  #   l_ids << liker.id.to_s
  #   media.update_attributes(liker_ids:l_ids.uniq.join(","))
  #   liker.add_like_media(media)
  # end


  def created_time(timezone)
    timezone = timezone.present? ? timezone.to_i : 0
    server_time_zone_offset = Time.now.gmt_offset
    offset = server_time_zone_offset / 60 / 60
    time = timezone + offset 
    created_time = created_at + time.hour    
    created_time.strftime("%Y-%m-%d %H:%M:%S")
  end

  def self.shared_medias(to_user)
    self.where({:shared_ids => /.*#{to_user.id.to_s}*./})
  end


  def self.medias_by_time(hour)
    server_time_zone_offset = Time.now.gmt_offset
    offset = server_time_zone_offset / 60 / 60
    # year  = Time.now.year
    # month = Time.now.month
    # day   = Time.now.day
    # @activities = @activities.where({:st_date.gte => st_time, :ed_date.lt => ed_time})
    # where("return this.created_at.getFullYear() == #{year} && this.date.getMonth() == #{month-1}")
    hour  = hour + offset
    st_time = hour < 0 ? DateTime.now.change(hour:hour) - 1.day : DateTime.now.change(hour:hour)
    ed_time = hour+1 < 0 ? DateTime.now.change(hour:hour+1) - 1.day : DateTime.now.change(hour:(hour+1))
    where({:created_at.gte => st_time, :created_at.lt => ed_time})    
  end  

  def self.clear(days=3)
    medias = self.where({created_at.lte => Time.now - days.days})
    medias.destroy_all
  end
end
